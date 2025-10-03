
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE dictionaries (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    lang_from VARCHAR(16),
    lang_to VARCHAR(16),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, title)
);

CREATE TABLE entries (
    id BIGSERIAL PRIMARY KEY,
    dictionary_id BIGINT NOT NULL REFERENCES dictionaries(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    normalized TEXT,
    transcription VARCHAR(100),
    part_of_speech VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE translations (
    id BIGSERIAL PRIMARY KEY,
    entry_id BIGINT NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    language VARCHAR(16),
    is_primary BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE examples (
    id BIGSERIAL PRIMARY KEY,
    entry_id BIGINT NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    translation TEXT
);

CREATE TABLE tags (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE entry_tags (
    entry_id BIGINT NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
    tag_id BIGINT NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY(entry_id, tag_id)
);

CREATE TABLE cards (
    id BIGSERIAL PRIMARY KEY,
    entry_id BIGINT NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
    card_type VARCHAR(30) NOT NULL,
    front_text TEXT,
    back_text TEXT,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE study_progress (
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    entry_id BIGINT NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
    ease_factor NUMERIC(5,2) NOT NULL DEFAULT 2.50,
    interval_days INTEGER NOT NULL DEFAULT 0,
    repetition INTEGER NOT NULL DEFAULT 0,
    next_review_at TIMESTAMPTZ,
    last_reviewed_at TIMESTAMPTZ,
    correct_count INTEGER NOT NULL DEFAULT 0,
    wrong_count INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY(user_id, entry_id)
);

CREATE TABLE review_attempts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    entry_id BIGINT NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
    card_id BIGINT REFERENCES cards(id) ON DELETE SET NULL,
    attempted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    result SMALLINT NOT NULL,
    quality SMALLINT,
    note TEXT
);
