CREATE TABLE job_applied (
    job_id INT,
    application_sent_date DATE,
    custom_resume BOOLEAN,
    resume_file_name VARCHAR(255),
    cover_letter_sent BOOLEAN,
    cover_letter_file_name VARCHAR(255),
    status VARCHAR(50)
);

SELECT * FROM job_applied;

INSERT INTO job_applied (
    job_id,
    application_sent_date,
    custom_resume,
    resume_file_name,
    cover_letter_sent,
    cover_letter_file_name,
    status )
VALUES
    (1, '2020-01-01', TRUE, 'resume1.pdf', TRUE, 'cover_letter1.pdf', 'pending'),
    (2, '2020-01-02', FALSE, 'resume2.pdf', FALSE, 'cover_letter2.pdf', 'rejected'),
    (3, '2020-01-03', TRUE, 'resume3.pdf', TRUE, 'cover_letter3.pdf', 'accepted'),
    (4, '2020-01-04', FALSE, 'resume4.pdf', FALSE, 'cover_letter4.pdf', 'pending'),
    (5, '2020-01-05', TRUE, 'resume5.pdf', TRUE, 'cover_letter5.pdf', 'rejected');


ALTER TABLE job_applied
ADD contact VARCHAR(50);

UPDATE job_applied
SET contact = 'John Doe'
WHERE job_id = 1;

UPDATE job_applied
SET contact = 'Jane Doe'
WHERE job_id = 2;

UPDATE job_applied
SET contact = 'Alice Smith'
WHERE job_id = 3;

UPDATE job_applied
SET contact = 'Bob Johnson'
WHERE job_id = 4;

UPDATE job_applied
SET contact = 'Charlie Brown'
WHERE job_id = 5;

ALTER TABLE job_applied
RENAME COLUMN contact TO contact_name;

Alter TABLE job_applied
ALTER COLUMN contact_name TYPE TEXT;

ALTER TABLE job_applied
DROP COLUMN contact_name;

DROP TABLE job_applied;
