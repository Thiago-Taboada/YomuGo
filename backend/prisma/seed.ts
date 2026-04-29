import { PrismaClient, Locale } from '@prisma/client';

const prisma = new PrismaClient();

const CATEGORY_CODES = [
  'pronouns',
  'verbs',
  'adjectives',
  'particles',
  'expressions',
  'daily_life',
  'food',
  'transport',
  'shopping',
  'time',
  'numbers',
  'family',
  'greetings',
  'farewells',
  'introductions',
  'casual_conversation',
  'common_questions',
  'friendship',
  'dating',
  'emotions',
  'opinions',
  'courtesy',
  'formality',
  'apologies',
  'gratitude',
  'requests',
] as const;

const CATEGORY_NAMES_ES: Record<(typeof CATEGORY_CODES)[number], string> = {
  pronouns: 'pronombres',
  verbs: 'verbos',
  adjectives: 'adjetivos',
  particles: 'partículas',
  expressions: 'expresiones',
  daily_life: 'vida diaria',
  food: 'comida',
  transport: 'transporte',
  shopping: 'compras',
  time: 'tiempo',
  numbers: 'números',
  family: 'familia',
  greetings: 'saludos',
  farewells: 'despedidas',
  introductions: 'presentaciones',
  casual_conversation: 'conversación casual',
  common_questions: 'preguntas comunes',
  friendship: 'amistad',
  dating: 'citas',
  emotions: 'emociones',
  opinions: 'opiniones',
  courtesy: 'cortesía',
  formality: 'formalidad',
  apologies: 'disculpas',
  gratitude: 'agradecimientos',
  requests: 'peticiones',
};

const CATEGORY_NAMES_PT: Record<(typeof CATEGORY_CODES)[number], string> = {
  pronouns: 'pronomes',
  verbs: 'verbos',
  adjectives: 'adjetivos',
  particles: 'partículas',
  expressions: 'expressões',
  daily_life: 'vida diária',
  food: 'comida',
  transport: 'transporte',
  shopping: 'compras',
  time: 'tempo',
  numbers: 'números',
  family: 'família',
  greetings: 'saudações',
  farewells: 'despedidas',
  introductions: 'apresentações',
  casual_conversation: 'conversa casual',
  common_questions: 'perguntas comuns',
  friendship: 'amizade',
  dating: 'encontros',
  emotions: 'emoções',
  opinions: 'opiniões',
  courtesy: 'cortesia',
  formality: 'formalidade',
  apologies: 'desculpas',
  gratitude: 'agradecimentos',
  requests: 'pedidos',
};

type SeedWord = {
  kanji: string | null;
  kana: string;
  romaji: string | null;
  level: string;
  frequency: number;
  partOfSpeech: string;
  categories: (typeof CATEGORY_CODES)[number][];
  meanings: { es: string; pt: string };
  example?: { japanese: string; es: string; pt: string };
};

const SEED_WORDS: SeedWord[] = [
  {
    kanji: '食べる',
    kana: 'たべる',
    romaji: 'taberu',
    level: 'N5',
    frequency: 100,
    partOfSpeech: 'verb',
    categories: ['verbs', 'food'],
    meanings: { es: 'comer', pt: 'comer' },
    example: {
      japanese: '私は寿司を食べます。',
      es: 'Yo como sushi.',
      pt: 'Eu como sushi.',
    },
  },
  {
    kanji: '行く',
    kana: 'いく',
    romaji: 'iku',
    level: 'N5',
    frequency: 101,
    partOfSpeech: 'verb',
    categories: ['verbs', 'transport'],
    meanings: { es: 'ir', pt: 'ir' },
  },
  {
    kanji: '来る',
    kana: 'くる',
    romaji: 'kuru',
    level: 'N5',
    frequency: 102,
    partOfSpeech: 'verb',
    categories: ['verbs'],
    meanings: { es: 'venir', pt: 'vir' },
  },
  {
    kanji: '見る',
    kana: 'みる',
    romaji: 'miru',
    level: 'N5',
    frequency: 103,
    partOfSpeech: 'verb',
    categories: ['verbs'],
    meanings: { es: 'ver', pt: 'ver' },
  },
  {
    kanji: '言う',
    kana: 'いう',
    romaji: 'iu',
    level: 'N5',
    frequency: 104,
    partOfSpeech: 'verb',
    categories: ['verbs'],
    meanings: { es: 'decir', pt: 'dizer' },
  },
  {
    kanji: '水',
    kana: 'みず',
    romaji: 'mizu',
    level: 'N5',
    frequency: 105,
    partOfSpeech: 'noun',
    categories: ['food', 'daily_life'],
    meanings: { es: 'agua', pt: 'água' },
  },
  {
    kanji: '本',
    kana: 'ほん',
    romaji: 'hon',
    level: 'N5',
    frequency: 106,
    partOfSpeech: 'noun',
    categories: ['daily_life'],
    meanings: { es: 'libro', pt: 'livro' },
  },
  {
    kanji: null,
    kana: 'わたし',
    romaji: 'watashi',
    level: 'N5',
    frequency: 107,
    partOfSpeech: 'pronoun',
    categories: ['pronouns'],
    meanings: { es: 'yo', pt: 'eu' },
  },
  {
    kanji: null,
    kana: 'あなた',
    romaji: 'anata',
    level: 'N5',
    frequency: 108,
    partOfSpeech: 'pronoun',
    categories: ['pronouns'],
    meanings: { es: 'tú / usted', pt: 'você' },
  },
  {
    kanji: '今日',
    kana: 'きょう',
    romaji: 'kyou',
    level: 'N5',
    frequency: 109,
    partOfSpeech: 'noun',
    categories: ['time'],
    meanings: { es: 'hoy', pt: 'hoje' },
  },
  {
    kanji: '明日',
    kana: 'あした',
    romaji: 'ashita',
    level: 'N5',
    frequency: 110,
    partOfSpeech: 'noun',
    categories: ['time'],
    meanings: { es: 'mañana', pt: 'amanhã' },
  },
  {
    kanji: '大きい',
    kana: 'おおきい',
    romaji: 'ookii',
    level: 'N5',
    frequency: 111,
    partOfSpeech: 'adjective',
    categories: ['adjectives'],
    meanings: { es: 'grande', pt: 'grande' },
  },
  {
    kanji: '小さい',
    kana: 'ちいさい',
    romaji: 'chiisai',
    level: 'N5',
    frequency: 112,
    partOfSpeech: 'adjective',
    categories: ['adjectives'],
    meanings: { es: 'pequeño', pt: 'pequeno' },
  },
  {
    kanji: null,
    kana: 'こんにちは',
    romaji: 'konnichiwa',
    level: 'N5',
    frequency: 113,
    partOfSpeech: 'expression',
    categories: ['greetings'],
    meanings: { es: 'hola / buenas tardes', pt: 'olá / boa tarde' },
  },
  {
    kanji: null,
    kana: 'ありがとう',
    romaji: 'arigatou',
    level: 'N5',
    frequency: 114,
    partOfSpeech: 'expression',
    categories: ['gratitude', 'courtesy'],
    meanings: { es: 'gracias', pt: 'obrigado/a' },
  },
];

function isKanjiChar(ch: string): boolean {
  return /[\u4E00-\u9FFF]/.test(ch);
}

async function main() {
  await prisma.message.deleteMany();
  await prisma.conversation.deleteMany();
  await prisma.userWordProgress.deleteMany();
  await prisma.userStats.deleteMany();
  await prisma.user.deleteMany();

  await prisma.wordCategory.deleteMany();
  await prisma.wordKanji.deleteMany();
  await prisma.exampleTranslation.deleteMany();
  await prisma.example.deleteMany();
  await prisma.wordTranslation.deleteMany();
  await prisma.word.deleteMany();
  await prisma.kanjiTranslation.deleteMany();
  await prisma.kanji.deleteMany();
  await prisma.categoryTranslation.deleteMany();
  await prisma.category.deleteMany();

  for (const code of CATEGORY_CODES) {
    await prisma.category.create({
      data: {
        code,
        translations: {
          create: [
            { locale: Locale.es, name: CATEGORY_NAMES_ES[code] },
            { locale: Locale.pt, name: CATEGORY_NAMES_PT[code] },
          ],
        },
      },
    });
  }

  const categories = await prisma.category.findMany();
  const codeToId = new Map(categories.map((c) => [c.code, c.id]));

  const kanjiCharToId = new Map<string, number>();
  for (const w of SEED_WORDS) {
    if (!w.kanji) continue;
    for (const ch of [...w.kanji]) {
      if (!isKanjiChar(ch)) continue;
      if (!kanjiCharToId.has(ch) && ch !== '々') {
        const exists = await prisma.kanji.findUnique({
          where: { character: ch },
        });
        if (exists) {
          kanjiCharToId.set(ch, exists.id);
          continue;
        }
        const k = await prisma.kanji.create({
          data: {
            character: ch,
            level: 'N5',
            strokeCount: null,
            frequency: null,
            onyomi: null,
            kunyomi: null,
            translations: {
              create: [
                { locale: Locale.es, meaning: ch },
                { locale: Locale.pt, meaning: ch },
              ],
            },
          },
        });
        kanjiCharToId.set(ch, k.id);
      }
    }
  }

  for (const w of SEED_WORDS) {
    const word = await prisma.word.create({
      data: {
        kanji: w.kanji,
        kana: w.kana,
        romaji: w.romaji,
        level: w.level,
        frequency: w.frequency,
        partOfSpeech: w.partOfSpeech,
        translations: {
          create: [
            { locale: Locale.es, meaning: w.meanings.es },
            { locale: Locale.pt, meaning: w.meanings.pt },
          ],
        },
        wordCategories: {
          create: w.categories.map((code) => ({
            categoryId: codeToId.get(code)!,
          })),
        },
      },
    });

    if (w.example) {
      const ex = await prisma.example.create({
        data: {
          wordId: word.id,
          japanese: w.example.japanese,
          source: 'manual',
          translations: {
            create: [
              { locale: Locale.es, translation: w.example.es },
              { locale: Locale.pt, translation: w.example.pt },
            ],
          },
        },
      });
      void ex;
    }

    if (w.kanji) {
      const uniqueChars = [...new Set([...w.kanji].filter(isKanjiChar))];
      for (const ch of uniqueChars) {
        const kid = kanjiCharToId.get(ch);
        if (kid) {
          await prisma.wordKanji.create({
            data: { wordId: word.id, kanjiId: kid },
          });
        }
      }
    }
  }

  // Enrich 食 kanji for demo (taberu)
  const taberu = await prisma.word.findFirst({
    where: { kana: 'たべる' },
  });
  const shokuKanji = await prisma.kanji.findUnique({
    where: { character: '食' },
  });
  if (taberu && shokuKanji) {
    await prisma.kanji.update({
      where: { id: shokuKanji.id },
      data: {
        onyomi: 'ショク',
        kunyomi: 'た(べる)',
        level: 'N5',
        strokeCount: 9,
        frequency: 120,
        translations: {
          deleteMany: {},
          create: [
            { locale: Locale.es, meaning: 'comida / comer' },
            { locale: Locale.pt, meaning: 'comida / comer' },
          ],
        },
      },
    });
    await prisma.wordKanji.upsert({
      where: {
        wordId_kanjiId: { wordId: taberu.id, kanjiId: shokuKanji.id },
      },
      create: { wordId: taberu.id, kanjiId: shokuKanji.id },
      update: {},
    });
  }
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
