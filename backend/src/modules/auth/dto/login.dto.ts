import { IsString, MinLength } from 'class-validator';

export class LoginDto {
  /** Nombre de usuario o email. */
  @IsString()
  @MinLength(1)
  identifier!: string;

  @IsString()
  @MinLength(1)
  password!: string;
}
