import {
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Query,
  DefaultValuePipe,
} from '@nestjs/common';
import { Locale } from '@prisma/client';
import { ResolvedLocale } from '../../common/decorators/resolved-locale.decorator';
import { WordsService } from './words.service';

@Controller('words')
export class WordsController {
  constructor(private readonly wordsService: WordsService) {}

  @Get()
  findMany(
    @ResolvedLocale() locale: Locale,
    @Query('level') level?: string,
    @Query('categoryId') categoryIdRaw?: string,
    @Query('partOfSpeech') partOfSpeech?: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page?: number,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit?: number,
  ) {
    const categoryId =
      categoryIdRaw !== undefined && categoryIdRaw !== ''
        ? Number.parseInt(categoryIdRaw, 10)
        : undefined;

    return this.wordsService.findMany({
      locale,
      level,
      categoryId: Number.isFinite(categoryId) ? categoryId : undefined,
      partOfSpeech,
      page,
      limit,
    });
  }

  @Get(':id')
  findOne(
    @Param('id', ParseIntPipe) id: number,
    @ResolvedLocale() locale: Locale,
  ) {
    return this.wordsService.findOne(id, locale);
  }
}
