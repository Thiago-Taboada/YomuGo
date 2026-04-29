import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

export type PaginatedResult<T> = {
  items: T[];
  page: number;
  limit: number;
  total: number;
};

function isPaginated(data: unknown): data is PaginatedResult<unknown> {
  if (!data || typeof data !== 'object') return false;
  const d = data as Record<string, unknown>;
  return (
    Array.isArray(d.items) &&
    typeof d.page === 'number' &&
    typeof d.limit === 'number' &&
    typeof d.total === 'number'
  );
}

@Injectable()
export class ResponseEnvelopeInterceptor implements NestInterceptor {
  intercept(
    _context: ExecutionContext,
    next: CallHandler,
  ): Observable<unknown> {
    return next.handle().pipe(
      map((data: unknown) => {
        if (isPaginated(data)) {
          const { items, page, limit, total } = data;
          const totalPages = limit > 0 ? Math.ceil(total / limit) : 0;
          return {
            success: true,
            data: items,
            meta: { page, limit, total, totalPages },
          };
        }
        return { success: true, data };
      }),
    );
  }
}
