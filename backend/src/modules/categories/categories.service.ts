import { Injectable, NotFoundException } from '@nestjs/common';
import { Locale } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class CategoriesService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(locale: Locale) {
    const categories = await this.prisma.category.findMany({
      orderBy: { id: 'asc' },
      include: {
        translations: {
          where: { locale },
        },
      },
    });

    return categories.map((c) => ({
      id: c.id,
      code: c.code,
      name: c.translations[0]?.name ?? c.code,
    }));
  }

  async findOne(id: number, locale: Locale) {
    const category = await this.prisma.category.findUnique({
      where: { id },
      include: {
        translations: {
          where: { locale },
        },
      },
    });
    if (!category) {
      throw new NotFoundException({
        code: 'CATEGORY_NOT_FOUND',
        message: 'La categoria no existe',
      });
    }
    return {
      id: category.id,
      code: category.code,
      name: category.translations[0]?.name ?? category.code,
    };
  }
}
