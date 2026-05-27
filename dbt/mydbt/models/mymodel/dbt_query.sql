SELECT
    employee_id,
    name,
    department,
    email
FROM {{ ref('EMPLOYEES') }}
ORDER BY department, employee_id