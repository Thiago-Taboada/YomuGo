import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { ResolvedLocale } from '../../common/decorators/resolved-locale.decorator';
import { Locale } from '@prisma/client';
import { CategoriesService } from './categories.service';

@Controller('categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Get()
  findAll(@ResolvedLocale() locale: Locale) {
    return this.categoriesService.findAll(locale);
  }

  @Get(':id')
  findOne(
    @Param('id', ParseIntPipe) id: number,
    @ResolvedLocale() locale: Locale,
  ) {
    return this.categoriesService.findOne(id, locale);
  }
}
