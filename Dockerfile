# Generated by https://smithery.ai. See: https://smithery.ai/docs/config#dockerfile
# Use a Python image with uv pre-installed
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS uv

# Set the working directory in the container
WORKDIR /app

# Copy the pyproject.toml and uv.lock to install dependencies
COPY pyproject.toml uv.lock ./

# Install the project's dependencies using uv
RUN --mount=type=cache,target=/root/.cache/uv uv sync --frozen --no-install-project --no-dev --no-editable

# Add the rest of the project source code
ADD src /app/src

# Install the project itself
RUN --mount=type=cache,target=/root/.cache/uv uv sync --frozen --no-dev --no-editable

# Create a new stage for the final release
FROM python:3.12-slim-bookworm

# Set the working directory
WORKDIR /app

# Copy the installed dependencies from the uv stage
COPY --from=uv /root/.local /root/.local
COPY --from=uv --chown=app:app /app/.venv /app/.venv

# Add the source code to the container
ADD src /app/src

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"

# Set environment variables for Twitter API keys
# These should be set during runtime or via a secrets manager
ENV TWITTER_API_KEY=your_api_key
ENV TWITTER_API_SECRET=your_api_secret
ENV TWITTER_ACCESS_TOKEN=your_access_token
ENV TWITTER_ACCESS_TOKEN_SECRET=your_access_token_secret

# Run the MCP server using uv
ENTRYPOINT ["uv", "run", "x-mcp"]
