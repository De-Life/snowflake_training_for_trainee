SELECT
    employee_id,
    name,
    department,
    email
FROM {{ ref('employees') }}
ORDER BY department, employee_id