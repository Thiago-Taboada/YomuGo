import {
  ConflictException,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { Locale, Prisma, UserRole } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

const BCRYPT_ROUNDS = 10;

const authUserSelect = {
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

export type SafeUser = Prisma.UserGetPayload<{ select: typeof authUserSelect }>;

function normalizeEmail(email: string): string {
  return email.trim().toLowerCase();
}

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto): Promise<{
    user: SafeUser;
    token: string;
  }> {
    const username = dto.username.trim();
    const email = normalizeEmail(dto.email);

    const existingUsername = await this.prisma.user.findUnique({
      where: { username },
    });
    if (existingUsername) {
      throw new ConflictException({
        code: 'USERNAME_TAKEN',
        message: 'El nombre de usuario ya existe',
      });
    }

    const existingEmail = await this.prisma.user.findUnique({
      where: { email },
    });
    if (existingEmail) {
      throw new ConflictException({
        code: 'EMAIL_TAKEN',
        message: 'El email ya está registrado',
      });
    }

    const passwordHash = await bcrypt.hash(dto.password, BCRYPT_ROUNDS);
    const preferredLocale = dto.preferredLocale ?? Locale.es;

    const user = await this.prisma.user.create({
      data: {
        username,
        email,
        passwordHash,
        role: UserRole.USER,
        preferredLocale,
        userStats: { create: {} },
      },
      select: authUserSelect,
    });

    const token = await this.signToken(user.id, user.username);
    return { user, token };
  }

  async login(dto: LoginDto): Promise<{
    user: SafeUser;
    token: string;
  }> {
    const raw = dto.identifier.trim();
    const byEmail = normalizeEmail(raw);

    const user = await this.prisma.user.findFirst({
      where: {
        OR: [{ username: raw }, { email: byEmail }],
      },
      select: {
        id: true,
        passwordHash: true,
        isActive: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException({
        code: 'INVALID_CREDENTIALS',
        message: 'Usuario o contraseña incorrectos',
      });
    }

    if (!user.isActive) {
      throw new ForbiddenException({
        code: 'ACCOUNT_DISABLED',
        message: 'Cuenta desactivada',
      });
    }

    const ok = await bcrypt.compare(dto.password, user.passwordHash);
    if (!ok) {
      throw new UnauthorizedException({
        code: 'INVALID_CREDENTIALS',
        message: 'Usuario o contraseña incorrectos',
      });
    }

    const updated = await this.prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
      select: authUserSelect,
    });

    const token = await this.signToken(updated.id, updated.username);
    return { user: updated, token };
  }

  private signToken(userId: number, username: string): Promise<string> {
    return this.jwtService.signAsync({
      sub: userId,
      username,
    });
  }
}
