-- CreateEnum
CREATE TYPE "Locale" AS ENUM ('es', 'pt');

-- CreateEnum
CREATE TYPE "MessageRole" AS ENUM ('user', 'assistant');

-- CreateTable
CREATE TABLE "users" (
    "id" SERIAL NOT NULL,
    "username" TEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "preferred_locale" "Locale" NOT NULL DEFAULT 'es',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "words" (
    "id" SERIAL NOT NULL,
    "kanji" TEXT,
    "kana" TEXT NOT NULL,
    "romaji" TEXT,
    "level" TEXT,
    "frequency" INTEGER,
    "part_of_speech" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "words_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "word_translations" (
    "id" SERIAL NOT NULL,
    "word_id" INTEGER NOT NULL,
    "locale" "Locale" NOT NULL,
    "meaning" TEXT NOT NULL,

    CONSTRAINT "word_translations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "kanji" (
    "id" SERIAL NOT NULL,
    "character" TEXT NOT NULL,
    "onyomi" TEXT,
    "kunyomi" TEXT,
    "level" TEXT,
    "stroke_count" INTEGER,
    "frequency" INTEGER,

    CONSTRAINT "kanji_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "kanji_translations" (
    "id" SERIAL NOT NULL,
    "kanji_id" INTEGER NOT NULL,
    "locale" "Locale" NOT NULL,
    "meaning" TEXT NOT NULL,

    CONSTRAINT "kanji_translations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "word_kanji" (
    "word_id" INTEGER NOT NULL,
    "kanji_id" INTEGER NOT NULL,

    CONSTRAINT "word_kanji_pkey" PRIMARY KEY ("word_id","kanji_id")
);

-- CreateTable
CREATE TABLE "examples" (
    "id" SERIAL NOT NULL,
    "word_id" INTEGER,
    "japanese" TEXT NOT NULL,
    "source" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "examples_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "example_translations" (
    "id" SERIAL NOT NULL,
    "example_id" INTEGER NOT NULL,
    "locale" "Locale" NOT NULL,
    "translation" TEXT NOT NULL,

    CONSTRAINT "example_translations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "categories" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,

    CONSTRAINT "categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "category_translations" (
    "id" SERIAL NOT NULL,
    "category_id" INTEGER NOT NULL,
    "locale" "Locale" NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "category_translations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "word_categories" (
    "word_id" INTEGER NOT NULL,
    "category_id" INTEGER NOT NULL,

    CONSTRAINT "word_categories_pkey" PRIMARY KEY ("word_id","category_id")
);

-- CreateTable
CREATE TABLE "user_word_progress" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "word_id" INTEGER NOT NULL,
    "correct_count" INTEGER NOT NULL DEFAULT 0,
    "incorrect_count" INTEGER NOT NULL DEFAULT 0,
    "last_seen" TIMESTAMP(3),
    "next_review" TIMESTAMP(3),
    "ease_factor" DOUBLE PRECISION NOT NULL DEFAULT 2.5,
    "interval_days" INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT "user_word_progress_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_stats" (
    "user_id" INTEGER NOT NULL,
    "total_words" INTEGER NOT NULL DEFAULT 0,
    "accuracy" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "total_study_time" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "user_stats_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "conversations" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "scenario" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "conversations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "messages" (
    "id" SERIAL NOT NULL,
    "conversation_id" INTEGER NOT NULL,
    "role" "MessageRole" NOT NULL,
    "content" TEXT NOT NULL,
    "correction" TEXT,
    "explanation" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "messages_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

-- CreateIndex
CREATE INDEX "idx_words_level" ON "words"("level");

-- CreateIndex
CREATE INDEX "idx_words_frequency" ON "words"("frequency");

-- CreateIndex
CREATE INDEX "idx_word_translations_word" ON "word_translations"("word_id");

-- CreateIndex
CREATE INDEX "idx_word_translations_locale" ON "word_translations"("locale");

-- CreateIndex
CREATE UNIQUE INDEX "word_translations_word_id_locale_key" ON "word_translations"("word_id", "locale");

-- CreateIndex
CREATE UNIQUE INDEX "kanji_character_key" ON "kanji"("character");

-- CreateIndex
CREATE INDEX "idx_kanji_level" ON "kanji"("level");

-- CreateIndex
CREATE INDEX "idx_kanji_translations_kanji" ON "kanji_translations"("kanji_id");

-- CreateIndex
CREATE INDEX "idx_kanji_translations_locale" ON "kanji_translations"("locale");

-- CreateIndex
CREATE UNIQUE INDEX "kanji_translations_kanji_id_locale_key" ON "kanji_translations"("kanji_id", "locale");

-- CreateIndex
CREATE INDEX "idx_examples_word" ON "examples"("word_id");

-- CreateIndex
CREATE INDEX "idx_example_translations_example" ON "example_translations"("example_id");

-- CreateIndex
CREATE INDEX "idx_example_translations_locale" ON "example_translations"("locale");

-- CreateIndex
CREATE UNIQUE INDEX "example_translations_example_id_locale_key" ON "example_translations"("example_id", "locale");

-- CreateIndex
CREATE UNIQUE INDEX "categories_code_key" ON "categories"("code");

-- CreateIndex
CREATE INDEX "idx_category_translations_category" ON "category_translations"("category_id");

-- CreateIndex
CREATE INDEX "idx_category_translations_locale" ON "category_translations"("locale");

-- CreateIndex
CREATE UNIQUE INDEX "category_translations_category_id_locale_key" ON "category_translations"("category_id", "locale");

-- CreateIndex
CREATE INDEX "idx_progress_user" ON "user_word_progress"("user_id");

-- CreateIndex
CREATE INDEX "idx_progress_next_review" ON "user_word_progress"("next_review");

-- CreateIndex
CREATE UNIQUE INDEX "user_word_progress_user_id_word_id_key" ON "user_word_progress"("user_id", "word_id");

-- CreateIndex
CREATE INDEX "idx_conversations_user" ON "conversations"("user_id");

-- CreateIndex
CREATE INDEX "idx_messages_conversation" ON "messages"("conversation_id");

-- AddForeignKey
ALTER TABLE "word_translations" ADD CONSTRAINT "word_translations_word_id_fkey" FOREIGN KEY ("word_id") REFERENCES "words"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "kanji_translations" ADD CONSTRAINT "kanji_translations_kanji_id_fkey" FOREIGN KEY ("kanji_id") REFERENCES "kanji"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "word_kanji" ADD CONSTRAINT "word_kanji_word_id_fkey" FOREIGN KEY ("word_id") REFERENCES "words"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "word_kanji" ADD CONSTRAINT "word_kanji_kanji_id_fkey" FOREIGN KEY ("kanji_id") REFERENCES "kanji"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "examples" ADD CONSTRAINT "examples_word_id_fkey" FOREIGN KEY ("word_id") REFERENCES "words"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "example_translations" ADD CONSTRAINT "example_translations_example_id_fkey" FOREIGN KEY ("example_id") REFERENCES "examples"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "category_translations" ADD CONSTRAINT "category_translations_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "categories"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "word_categories" ADD CONSTRAINT "word_categories_word_id_fkey" FOREIGN KEY ("word_id") REFERENCES "words"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "word_categories" ADD CONSTRAINT "word_categories_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "categories"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_word_progress" ADD CONSTRAINT "user_word_progress_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_word_progress" ADD CONSTRAINT "user_word_progress_word_id_fkey" FOREIGN KEY ("word_id") REFERENCES "words"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_stats" ADD CONSTRAINT "user_stats_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversations" ADD CONSTRAINT "conversations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "messages" ADD CONSTRAINT "messages_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "conversations"("id") ON DELETE CASCADE ON UPDATE CASCADE;
