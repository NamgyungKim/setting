# shell alias를 ~/.zshrc에 추가
ALIASES=(
  "alias ghist='git hist'" 
  "alias gca='git back'" 
)

for a in "${ALIASES[@]}"; do
  if ! grep -qF "$a" ~/.zshrc 2>/dev/null; then
    echo "$a" >> ~/.zshrc
    echo "Added: $a"
  fi
done

echo "✅ Shell aliases configured in ~/.zshrc"