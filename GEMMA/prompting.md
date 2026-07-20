# Prompting Conventions for Gemma

*   **Be Specific:** Provide clear, explicit, detailed and precise instructions in your prompts. Avoid ambiguity.  The more detail you provide, the better Gemma can understand your intent.
*   **Define Roles:** Explicitly state the role Gemma should assume (e.g., "You are a financial analyst...").
*   **Constraints:** Include constraints on the desired output format, length, or content (e.g., “Summarize this report in no more than 100 words”).
*   **Few-Shot Examples:**  Provide a few examples of desired input/output pairs to guide Gemma's responses.  This significantly improves performance, especially for complex tasks.
*   **Iterative Refinement:** Start with a simple prompt and iteratively refine it based on Gemma’s outputs. Don't expect perfection in the first attempt.
*   **Use Delimiters**: Use delimiters like ``` or ### to clearly separate different sections of the prompt or input text.  This helps Gemma parse complex instructions accurately.