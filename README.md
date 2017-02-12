Source code to the [CharlieStar project on mitxela.com](http://mitxela.com/projects/charliestar). Runs on an ATtiny9, drives six charlieplexed LEDs from the three IO pins. Works great with a 3V lithium coin cell. Pressing the reset switch cycles through the following modes:

* pulsate in a swirling pattern
* flash a message in morse code
* flicker (uses a pseudorandom number generator)
* power-off

The morse code message is in program memory at line 342, it's a zero-terminated string that can be up to 127 characters. 
