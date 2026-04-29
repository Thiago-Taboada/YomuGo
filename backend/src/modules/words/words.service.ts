import { Injectable, NotFoundException } from '@nestjs/common';
import { Locale, Prisma } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import type { PaginatedResult } from '../../common/interceptors/response-envelope.interceptor';

export type ListWordsQuery = {
  locale: Locale;
  level?: string;
  categoryId?: number;
  partOfSpeech?: string;
  page?: number;
  limit?: number;
};

@Injectable()
export class WordsService {
  constructor(private readonly prisma: PrismaService) {}

  async findMany(query: ListWordsQuery): Promise<
    PaginatedResult<{
      id: number;
      kanji: string | null;
      kana: string;
      romaji: string | null;
      meaning: string;
      level: string | null;
      partOfSpeech: string | null;
    }>
  > {
    const page = Math.max(1, query.page ?? 1);
    const limit = Math.min(100, Math.max(1, query.limit ?? 20));
    const skip = (page - 1) * limit;

    const where: Prisma.WordWhereInput = {
      translations: { some: { locale: query.locale } },
      ...(query.level ? { level: query.level } : {}),
      ...(query.partOfSpeech ? { partOfSpeech: query.partOfSpeech } : {}),
      ...(query.categoryId
        ? {
            wordCategories: {
              some: { categoryId: query.categoryId },
            },
          }
        : {}),
    };

    const [total, words] = await this.prisma.$transaction([
      this.prisma.word.count({ where }),
      this.prisma.word.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ frequency: 'asc' }, { id: 'asc' }],
        include: {
          translations: {
            where: { locale: query.locale },
          },
        },
      }),
    ]);

    const items = words.map((w) => ({
      id: w.id,
      kanji: w.kanji,
      kana: w.kana,
      romaji: w.romaji,
      meaning: w.translations[0]?.meaning ?? '',
      level: w.level,
      partOfSpeech: w.partOfSpeech,
    }));

    return { items, page, limit, total };
  }

  async findOne(id: number, locale: Locale) {
    const word = await this.prisma.word.findUnique({
      where: { id },
      include: {
        translations: { where: { locale } },
        examples: {
          orderBy: { id: 'asc' },
          include: {
            translations: { where: { locale } },
          },
        },
        wordCategories: {
          include: {
            category: {
              include: {
                translations: { where: { locale } },
              },
            },
          },
        },
        wordKanji: {
          include: {
            kanji: {
              include: {
                translations: { where: { locale } },
              },
            },
          },
        },
      },
    });

    if (!word) {
      throw new NotFoundException({
        code: 'WORD_NOT_FOUND',
        message: 'La palabra no existe',
      });
    }

    return {
      id: word.id,
      kanji: word.kanji,
      kana: word.kana,
      romaji: word.romaji,
      meaning: word.translations[0]?.meaning ?? '',
      level: word.level,
      partOfSpeech: word.partOfSpeech,
      categories: word.wordCategories.map((wc) => ({
        id: wc.category.id,
        name: wc.category.translations[0]?.name ?? wc.category.code,
      })),
      examples: word.examples.map((ex) => ({
        id: ex.id,
        japanese: ex.japanese,
        translation: ex.translations[0]?.translation ?? '',
      })),
      kanjiItems: word.wordKanji.map((wk) => ({
        id: wk.kanji.id,
        character: wk.kanji.character,
        meaning: wk.kanji.translations[0]?.meaning ?? '',
      })),
    };
  }
}
