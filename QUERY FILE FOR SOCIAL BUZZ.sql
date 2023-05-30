CREATE DATABASE social_buzz_analysis;

/*Two parts of the cleaning (removing columns, changing data types) could have been done in the Table Data Import Wizard
Now we want to
1)remove unnecessary columns to our analysis
2)remove rows with empty cells
3)change data type of some columns
*/

#removing unnecessary columns
#backticks are used because of whitespace in column titles
ALTER TABLE content
DROP COLUMN MyUnknownColumn,
DROP COLUMN `User ID`,
DROP COLUMN URL;

ALTER TABLE reactions
DROP COLUMN MyUnknownColumn,
DROP COLUMN `User ID`;

ALTER TABLE reactiontypes
DROP COLUMN MyUnknownColumn,
DROP COLUMN Sentiment;

#removing rows with empty cells
#First used IS NULL, but remembered that blank cells and NULL are not equivalent
DELETE FROM content 
WHERE `Content ID` = '' OR `Type` = '' OR Category ='';
DELETE FROM reactions
WHERE `Content ID` = '' OR `Type` = '' OR Datetime ='';
DELETE FROM reactiontypes
WHERE `Type` = '' OR Score = '';

#changing data types of columns
DESCRIBE content; #datatypes are fine in this table

DESCRIBE reactions; #datetime column is not in the correct datatype
ALTER TABLE reactions ADD new_datetime DATE;
UPDATE reactions SET new_datetime = STR_TO_DATE(datetime, '%Y-%m-%d %H:%i:%s');
ALTER TABLE reactions DROP COLUMN datetime;

DESCRIBE reactiontypes; #datatypes are fine in this table

#Final step of cleaning
#category names were repeated with quotation marks (noticed this in excel)
SELECT DISTINCT Category from content; 
DELETE FROM content
WHERE category LIKE '"%';

#let's rename type column in each table
ALTER TABLE content
RENAME COLUMN type TO content_type;

ALTER TABLE reactions
RENAME COLUMN type TO reaction_type;

ALTER TABLE reactiontypes
RENAME COLUMN type TO reaction_type;

#------------------------------------------------ANALYSIS BEGINS---------------------------------------------------#

#We'll create a view to be used for all the insights
create view cleaned_table AS
SELECT content.content_type, content.category, reactions.reaction_type, reactions.new_datetime, reactiontypes.Score
FROM reactions JOIN content on reactions.`Content ID` = content.`Content ID` 
JOIN reactiontypes ON reactions.reaction_type = reactiontypes.reaction_type;

#Top 5 most popular categories
SELECT category, sum(Score) AS Score
FROM cleaned_table
GROUP BY category
ORDER BY Score desc
LIMIT 5;

/*OTHER INSIGHTS SUCH AS:
1) How many reactions for most popular category?
2) What is the Busiest Month?
3) How many unique categories? */

SELECT count(reaction_type) AS number_of_reactions
FROM cleaned_table
WHERE category = 'animals';

SELECT month(new_datetime) AS months, count(reaction_type) as number_of_reactions
FROM cleaned_table
GROUP BY months
ORDER BY number_of_reactions DESC
LIMIT 1; #so the busiest month is May

SELECT count(distinct category) AS Number_of_Categories
FROM cleaned_table;

