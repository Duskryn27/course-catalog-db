## Index Performance Experiment

### Objective

The goal of this experiment is to compare query performance before and after creating an index on the `student_id` column in the `enrollments` table.

### Test Data

The experiment used the following dataset:

- 500 courses
- 20,000 students
- 50,000 enrollments

The data was generated using `generate_series()`. The `ANALYZE` command was executed to update PostgreSQL statistics before testing.

### Query

```sql
EXPLAIN ANALYZE
SELECT *
FROM enrollments
WHERE student_id = 777;
```

### Results

| Metric | Before Index | After Index |
|---|---:|---:|
| Scan method | Seq Scan | Bitmap Heap Scan + Bitmap Index Scan |
| Execution Time | 3.306 ms | 0.083 ms |
| Matching rows | 3 | 3 |
| Rows removed by filter | 49,997 | Not reported |

The index was created using:

```sql
CREATE INDEX enrollments_student_id_idx
ON enrollments (student_id);
```

### Analysis

Before the index was created, PostgreSQL used a sequential scan and checked all 50,000 rows to find the matching enrollments. The query took 3.306 ms.

After the index was created, PostgreSQL used a bitmap index scan to locate matching rows and a bitmap heap scan to retrieve them. The execution time decreased to 0.083 ms, making this query approximately 39.8 times faster in this measurement.

### Questions

**1. Why did the query become faster?**

The index allows PostgreSQL to locate rows by `student_id` without scanning the entire table.

**2. Why did PostgreSQL use a Bitmap Index Scan instead of an Index Scan?**

PostgreSQL selected the execution plan it estimated to be most efficient for this query. The bitmap approach identifies matching rows and then retrieves the relevant table pages.

**3. Does an index always improve query performance?**

No. Indexes can speed up data retrieval, but they require storage and add overhead to insert, update, and delete operations. The PostgreSQL planner chooses a plan based on statistics and estimated costs.
