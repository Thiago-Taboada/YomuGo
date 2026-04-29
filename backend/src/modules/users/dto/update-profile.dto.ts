import {
  IsEmail,
  IsIn,
  IsOptional,
  IsString,
  MinLength,
} from 'class-validator';
import { Locale } from '@prisma/client';

/** Actualización de perfil propio (sin cambiar rol). */
export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  @MinLength(2)
  username?: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  @MinLength(6)
  password?: string;

  @IsOptional()
  @IsIn([Locale.es, Locale.pt])
  preferredLocale?: Locale;

  /** Base64 de la imagen (p. ej. data:image/png;base64,...). Cadena vacía la borra. */
  @IsOptional()
  @IsString()
  profileImageBase64?: string;
}
