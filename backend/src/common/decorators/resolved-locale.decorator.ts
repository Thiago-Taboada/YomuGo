import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { Locale } from '@prisma/client';
import type { RequestUser } from './current-user.decorator';

function parseLocale(value: string | undefined): Locale | null {
  if (value === Locale.es || value === Locale.pt) {
    return value;
  }
  return null;
}

/**
 * Resolves locale: query `locale` > Accept-Language > authenticated user's preferredLocale > DEFAULT_LOCALE.
 */
export const ResolvedLocale = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): Locale => {
    const request = ctx.switchToHttp().getRequest<{
      query: Record<string, unknown>;
      headers: Record<string, unknown>;
      user?: RequestUser;
    }>();

    const fromQuery = parseLocale(request.query?.locale as string | undefined);
    if (fromQuery) return fromQuery;

    const accept = request.headers['accept-language'];
    if (typeof accept === 'string') {
      const lower = accept.toLowerCase();
      if (lower.includes('pt')) return Locale.pt;
      if (lower.includes('es')) return Locale.es;
    }

    const user = request.user;
    if (user?.preferredLocale) {
      return user.preferredLocale;
    }

    const def = process.env.DEFAULT_LOCALE;
    return parseLocale(def) ?? Locale.es;
  },
);
