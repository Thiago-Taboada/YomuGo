import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { Locale, UserRole } from '@prisma/client';

/** Usuario inyectado por JwtStrategy (sin contraseña). */
export type RequestUser = {
  id: number;
  username: string;
  email: string;
  role: UserRole;
  preferredLocale: Locale;
  createdAt: Date;
  updatedAt: Date;
  isActive: boolean;
  emailVerified: boolean;
  lastLoginAt: Date | null;
  profileImageBase64: string | null;
};

export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): RequestUser | undefined => {
    const request = ctx.switchToHttp().getRequest<{ user?: RequestUser }>();
    return request.user;
  },
);
