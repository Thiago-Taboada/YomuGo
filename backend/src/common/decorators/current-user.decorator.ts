import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { Locale } from '@prisma/client';

/** JWT payload user shape attached by JwtStrategy (no password). */
export type RequestUser = {
  id: number;
  username: string;
  preferredLocale: Locale;
  createdAt: Date;
};

export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): RequestUser | undefined => {
    const request = ctx.switchToHttp().getRequest<{ user?: RequestUser }>();
    return request.user;
  },
);
