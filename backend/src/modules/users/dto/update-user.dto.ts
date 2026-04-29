import { IsIn, IsOptional } from 'class-validator';
import { Locale } from '@prisma/client';

export class UpdateUserDto {
  @IsOptional()
  @IsIn([Locale.es, Locale.pt])
  preferredLocale?: Locale;
}
