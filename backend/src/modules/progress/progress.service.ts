import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class ProgressService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Basic dashboard from user_stats. Extended metrics (streak, weekly, modules)
   * are placeholders until practice sessions / events exist (Phase 2+).
   */
  async getDashboard(userId: number) {
    const stats = await this.prisma.userStats.findUnique({
      where: { userId },
    });

    const totalWords = stats?.totalWords ?? 0;
    const accuracy = stats?.accuracy ?? 0;
    const totalStudyTime = stats?.totalStudyTime ?? 0;

    return {
      currentLevel: 'N5',
      wordsLearned: totalWords,
      accuracy,
      totalStudyTime,
      streakDays: 0,
      weeklyHistory: [] as { day: string; minutes: number }[],
      moduleProgress: [] as { module: string; progress: number }[],
      strongModules: [] as string[],
      weakModules: [] as string[],
    };
  }
}
