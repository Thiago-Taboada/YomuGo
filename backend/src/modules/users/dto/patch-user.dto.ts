import { IsBoolean, IsEnum, IsOptional } from 'class-validator';
import { UserRole } from '@prisma/client';
import { UpdateProfileDto } from './update-profile.dto';

/** PATCH /users/:id — rol y flags solo para administradores (validado en servicio). */
export class PatchUserDto extends UpdateProfileDto {
  @IsOptional()
  @IsEnum(UserRole)
  role?: UserRole;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @IsOptional()
  @IsBoolean()
  emailVerified?: boolean;
}
