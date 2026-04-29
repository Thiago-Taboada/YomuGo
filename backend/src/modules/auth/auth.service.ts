import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { Locale } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

const BCRYPT_ROUNDS = 10;

export type SafeUser = {
  id: number;
  username: string;
  preferredLocale: Locale;
  createdAt: Date;
};

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
    const existing = await this.prisma.user.findUnique({
      where: { username: dto.username },
    });
    if (existing) {
      throw new ConflictException({
        code: 'USERNAME_TAKEN',
        message: 'El nombre de usuario ya existe',
      });
    }

    const passwordHash = await bcrypt.hash(dto.password, BCRYPT_ROUNDS);
    const preferredLocale = dto.preferredLocale ?? Locale.es;

    const user = await this.prisma.user.create({
      data: {
        username: dto.username,
        passwordHash,
        preferredLocale,
        userStats: { create: {} },
      },
      select: {
        id: true,
        username: true,
        preferredLocale: true,
        createdAt: true,
      },
    });

    const token = await this.signToken(user.id, user.username);
    return { user, token };
  }

  async login(dto: LoginDto): Promise<{
    user: SafeUser;
    token: string;
  }> {
    const user = await this.prisma.user.findUnique({
      where: { username: dto.username },
    });
    if (!user) {
      throw new UnauthorizedException({
        code: 'INVALID_CREDENTIALS',
        message: 'Usuario o contrasena incorrectos',
      });
    }

    const ok = await bcrypt.compare(dto.password, user.passwordHash);
    if (!ok) {
      throw new UnauthorizedException({
        code: 'INVALID_CREDENTIALS',
        message: 'Usuario o contrasena incorrectos',
      });
    }

    const safe = {
      id: user.id,
      username: user.username,
      preferredLocale: user.preferredLocale,
      createdAt: user.createdAt,
    };
    const token = await this.signToken(user.id, user.username);
    return { user: safe, token };
  }

  private signToken(userId: number, username: string): Promise<string> {
    return this.jwtService.signAsync({
      sub: userId,
      username,
    });
  }
}
