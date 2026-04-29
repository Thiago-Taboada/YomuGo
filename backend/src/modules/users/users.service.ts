import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../prisma/prisma.service';
import type { RequestUser } from '../../common/decorators/current-user.decorator';
import { CreateUserDto } from './dto/create-user.dto';
import { PatchUserDto } from './dto/patch-user.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';

const BCRYPT_ROUNDS = 10;

const userPublicSelect = {
  id: true,
  username: true,
  email: true,
  role: true,
  isActive: true,
  emailVerified: true,
  lastLoginAt: true,
  profileImageBase64: true,
  preferredLocale: true,
  createdAt: true,
  updatedAt: true,
} satisfies Prisma.UserSelect;

export type UserPublic = Prisma.UserGetPayload<{
  select: typeof userPublicSelect;
}>;

function normalizeEmail(email: string): string {
  return email.trim().toLowerCase();
}

function isPrismaUniqueViolation(e: unknown): boolean {
  return (
    typeof e === 'object' &&
    e !== null &&
    'code' in e &&
    (e as { code: string }).code === 'P2002'
  );
}

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateUserDto): Promise<UserPublic> {
    const email = normalizeEmail(dto.email);
    const passwordHash = await bcrypt.hash(dto.password, BCRYPT_ROUNDS);
    const role = dto.role ?? UserRole.USER;

    try {
      return await this.prisma.user.create({
        data: {
          username: dto.username.trim(),
          email,
          passwordHash,
          role,
          isActive: dto.isActive ?? true,
          emailVerified: dto.emailVerified ?? false,
          profileImageBase64: dto.profileImageBase64?.length
            ? dto.profileImageBase64
            : null,
          preferredLocale: dto.preferredLocale ?? undefined,
          userStats: { create: {} },
        },
        select: userPublicSelect,
      });
    } catch (e) {
      if (isPrismaUniqueViolation(e)) {
        const target = (e as { meta?: { target?: string[] } }).meta?.target;
        if (target?.includes('email')) {
          throw new ConflictException({
            code: 'EMAIL_TAKEN',
            message: 'El email ya está registrado',
          });
        }
        throw new ConflictException({
          code: 'USERNAME_TAKEN',
          message: 'El nombre de usuario ya existe',
        });
      }
      throw e;
    }
  }

  async findAll(page = 1, limit = 20) {
    const p = Math.max(1, page);
    const l = Math.min(100, Math.max(1, limit));
    const skip = (p - 1) * l;

    const [total, items] = await this.prisma.$transaction([
      this.prisma.user.count(),
      this.prisma.user.findMany({
        skip,
        take: l,
        orderBy: { id: 'asc' },
        select: userPublicSelect,
      }),
    ]);

    return { items, page: p, limit: l, total };
  }

  async findOne(id: number): Promise<UserPublic> {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: userPublicSelect,
    });
    if (!user) {
      throw new NotFoundException({
        code: 'USER_NOT_FOUND',
        message: 'Usuario no encontrado',
      });
    }
    return user;
  }

  async findOneForActor(id: number, actor: RequestUser): Promise<UserPublic> {
    if (actor.role !== UserRole.ADMIN && actor.id !== id) {
      throw new ForbiddenException({
        code: 'FORBIDDEN',
        message: 'No puedes ver este usuario',
      });
    }
    return this.findOne(id);
  }

  async findMe(actor: RequestUser): Promise<UserPublic> {
    return this.findOne(actor.id);
  }

  async getSettings(userId: number) {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: { preferredLocale: true },
    });
    return { preferredLocale: user.preferredLocale };
  }

  async updateProfile(
    userId: number,
    dto: UpdateProfileDto,
  ): Promise<UserPublic> {
    return this.applyUserPatch(userId, dto, {});
  }

  async updateForActor(
    id: number,
    actor: RequestUser,
    dto: PatchUserDto,
  ): Promise<UserPublic> {
    const isAdmin = actor.role === UserRole.ADMIN;
    if (!isAdmin && actor.id !== id) {
      throw new ForbiddenException({
        code: 'FORBIDDEN',
        message: 'No puedes editar este usuario',
      });
    }

    if (
      !isAdmin &&
      (dto.role !== undefined ||
        dto.isActive !== undefined ||
        dto.emailVerified !== undefined)
    ) {
      throw new ForbiddenException({
        code: 'FORBIDDEN',
        message: 'No puedes cambiar rol, isActive ni emailVerified',
      });
    }

    const {
      role,
      isActive,
      emailVerified,
      ...profileFields
    } = dto;

    const extra: Prisma.UserUpdateInput = {};
    if (isAdmin) {
      if (role !== undefined) extra.role = role;
      if (isActive !== undefined) extra.isActive = isActive;
      if (emailVerified !== undefined) extra.emailVerified = emailVerified;
    }

    return this.applyUserPatch(id, profileFields, extra);
  }

  private async applyUserPatch(
    userId: number,
    profile: UpdateProfileDto,
    extra: Prisma.UserUpdateInput,
  ): Promise<UserPublic> {
    const data: Prisma.UserUpdateInput = { ...extra };

    if (profile.username !== undefined) {
      data.username = profile.username.trim();
    }
    if (profile.email !== undefined) {
      data.email = normalizeEmail(profile.email);
    }
    if (profile.preferredLocale !== undefined) {
      data.preferredLocale = profile.preferredLocale;
    }
    if (profile.password !== undefined) {
      data.passwordHash = await bcrypt.hash(profile.password, BCRYPT_ROUNDS);
    }
    if (profile.profileImageBase64 !== undefined) {
      const v = profile.profileImageBase64;
      data.profileImageBase64 = v.length === 0 ? null : v;
    }

    if (Object.keys(data).length === 0) {
      return this.findOne(userId);
    }

    try {
      return await this.prisma.user.update({
        where: { id: userId },
        data,
        select: userPublicSelect,
      });
    } catch (e) {
      if (isPrismaUniqueViolation(e)) {
        const target = (e as { meta?: { target?: string[] } }).meta?.target;
        if (target?.includes('email')) {
          throw new ConflictException({
            code: 'EMAIL_TAKEN',
            message: 'El email ya está en uso',
          });
        }
        throw new ConflictException({
          code: 'USERNAME_TAKEN',
          message: 'El nombre de usuario ya está en uso',
        });
      }
      if (
        typeof e === 'object' &&
        e !== null &&
        'code' in e &&
        (e as { code: string }).code === 'P2025'
      ) {
        throw new NotFoundException({
          code: 'USER_NOT_FOUND',
          message: 'Usuario no encontrado',
        });
      }
      throw e;
    }
  }

  async removeByAdmin(id: number): Promise<void> {
    try {
      await this.prisma.user.delete({ where: { id } });
    } catch (e) {
      if (
        typeof e === 'object' &&
        e !== null &&
        'code' in e &&
        (e as { code: string }).code === 'P2025'
      ) {
        throw new NotFoundException({
          code: 'USER_NOT_FOUND',
          message: 'Usuario no encontrado',
        });
      }
      throw e;
    }
  }

  async removeSelf(userId: number): Promise<void> {
    await this.removeByAdmin(userId);
  }
}
