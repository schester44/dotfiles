// Fibonacci sequence generator

function fibonacci(n) {
  if (n <= 0) return [];
  if (n === 1) return [0];
  if (n === 2) return [0, 1];

  const sequence = [0, 1];
  for (let i = 2; i < n; i++) {
    sequence.push(sequence[i - 1] + sequence[i - 2]);
  }
  return sequence;
}

// Generate first 20 Fibonacci numbers
const count = 20;
const result = fibonacci(count);

console.log(`First ${count} Fibonacci numbers:`);
console.log(result.join(', '));

// Also show them individually
console.log('\nDetailed view:');
result.forEach((num, index) => {
  console.log(`F(${index}) = ${num}`);
});
