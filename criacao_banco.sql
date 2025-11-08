USE tintin_db

DROP TABLE IF EXISTS users;
CREATE TABLE users 
(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone VARCHAR(11) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    photo_url TEXT,
    bio TEXT,
    user_type TEXT NOT NULL CHECK(user_type IN ('student', 'teacher')),
    -- Campos adicionais para melhorar informações do usuário
    location TEXT,
    languages TEXT,
    availability TEXT,
    price_per_hour REAL,
    credentials TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
    
DROP TABLE IF EXISTS  teacher_skills;
CREATE TABLE teacher_skills 
(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    skill_name TEXT NOT NULL,
    skill_description TEXT,
    -- nível/competência da habilidade (opcional)
    skill_level TEXT,
    -- se o professor exige alguma avaliação/entrevista para ensinar essa habilidade
    requires_evaluation BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS student_interests;     
CREATE TABLE student_interests 
(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    interest_name TEXT NOT NULL,
    difficulty_level TEXT CHECK(difficulty_level IN ('beginner', 'intermediate', 'advanced')),
    description TEXT,
    -- nível/expectativa do aluno (p.ex. "beginner")
    desired_level TEXT,
    -- se o aluno solicita avaliação ou verificação antes de iniciar
    requires_evaluation BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS swipes;      
CREATE TABLE swipes 
(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    from_user_id INTEGER NOT NULL,
    to_user_id INTEGER NOT NULL,
    swipe_type TEXT NOT NULL CHECK(swipe_type IN ('like', 'skip')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (from_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (to_user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(from_user_id, to_user_id)
);

DROP TABLE IF EXISTS matches;
CREATE TABLE matches (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user1_id INTEGER NOT NULL,
    user2_id INTEGER NOT NULL,
    matched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT 1,
    FOREIGN KEY (user1_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (user2_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(user1_id, user2_id)
);

DROP TABLE IF EXISTS messages;
CREATE TABLE messages 
(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    match_id INTEGER NOT NULL,
    sender_id INTEGER NOT NULL,
    message_text TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT 0,
    FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings 
(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    match_id INTEGER NOT NULL,
    rater_id INTEGER NOT NULL,
    rated_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK(rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE,
    FOREIGN KEY (rater_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (rated_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(match_id, rater_id)
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)
CREATE INDEX IF NOT EXISTS idx_swipes_users ON swipes(from_user_id, to_user_id)
CREATE INDEX IF NOT EXISTS idx_matches_users ON matches(user1_id, user2_id)
CREATE INDEX IF NOT EXISTS idx_messages_match ON messages(match_id)
CREATE INDEX IF NOT EXISTS idx_teacher_skills_user ON teacher_skills(user_id)
CREATE INDEX IF NOT EXISTS idx_student_interests_user ON student_interests(user_id)
CREATE INDEX IF NOT EXISTS idx_teacher_skills_name ON teacher_skills(skill_name)
CREATE INDEX IF NOT EXISTS idx_student_interests_name ON student_interests(interest_name)