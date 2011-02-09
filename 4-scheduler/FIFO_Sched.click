// FIFO_Sched.click
// Simulate FIFO scheduler with at most 10 inputs (flows)

elementclass FFSched1 {
  tss::TimeSortedSched;
  input[0] -> q0::Queue(1000) -> [0]tss;
  input[1] -> q1::Queue(1000) -> [1]tss;
  input[2] -> q2::Queue(1000) -> [2]tss;
  input[3] -> q3::Queue(1000) -> [3]tss;
  input[4] -> q4::Queue(1000) -> [4]tss;
  input[5] -> q5::Queue(1000) -> [5]tss;
  input[6] -> q6::Queue(1000) -> [6]tss;
  input[7] -> q7::Queue(1000) -> [7]tss;
  input[8] -> q8::Queue(1000) -> [8]tss;
  input[9] -> q9::Queue(1000) -> [9]tss;
  tss -> output;
}

elementclass FFSched2 {
  queue::ThreadSafeQueue(20);
  input[0] -> queue;
  input[1] -> queue;
  input[2] -> queue;
  input[3] -> queue;
  input[4] -> queue;
  input[5] -> queue;
  input[6] -> queue;
  input[7] -> queue;
  input[8] -> queue;
  input[9] -> queue;
  queue -> output;
}

