import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async updateMe(userId: number, dto: UpdateUserDto) {
    return this.prisma.user.update({
      where: { id: userId },
      data: {
        ...(dto.preferredLocale !== undefined
          ? { preferredLocale: dto.preferredLocale }
          : {}),
      },
      select: {
        id: true,
        username: true,
        preferredLocale: true,
        createdAt: true,
      },
    });
  }

  async getSettings(userId: number) {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: { preferredLocale: true },
    });
    return { preferredLocale: user.preferredLocale };
  }
}
