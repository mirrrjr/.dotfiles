#!/usr/bin/env bash
# Nvim uchun LSP serverlar va conform formatterlarini o'rnatadi.
# Ishlatish:
#   ./install-nvim-tools.sh          # hammasi (LSP + formatter)
#   ./install-nvim-tools.sh --lsp    # faqat LSP serverlar
#   ./install-nvim-tools.sh --fmt    # faqat formatterlar
#
# Maqsad platforma: Linux x86_64 (Debian / WSL)

set -uo pipefail

BIN_DIR="$HOME/.local/bin"
SHARE_DIR="$HOME/.local/share"
mkdir -p "$BIN_DIR" "$SHARE_DIR"
export PATH="$BIN_DIR:$HOME/.cargo/bin:$PATH"
export GOBIN="$BIN_DIR" # go install shu yerga tushadi, bitta PATH yetarli

DO_LSP=1
DO_FMT=1
case "${1:-}" in
--lsp) DO_FMT=0 ;;
--fmt) DO_LSP=0 ;;
"") ;;
*)
	echo "Noma'lum flag: $1 (--lsp yoki --fmt)"
	exit 1
	;;
esac

OK=()
SKIPPED=()
FAILED=()

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# run <nom> <tekshiriladigan binary> <buyruq...>
run() {
	local name="$1" bin="$2"
	shift 2
	if have "$bin"; then
		echo "  [bor] $name"
		SKIPPED+=("$name")
		return
	fi
	echo "  [o'rnatilmoqda] $name"
	if "$@"; then
		OK+=("$name")
	else
		echo "  [XATO] $name"
		FAILED+=("$name")
	fi
}

need() {
	# need <asbob> <nom...>: asbob yo'q bo'lsa, shu nomlarni FAILED ga qo'shib False qaytaradi
	local tool="$1"
	shift
	if have "$tool"; then return 0; fi
	echo "  [!] '$tool' topilmadi, o'tkazib yuborildi: $*"
	FAILED+=("$* (${tool} yo'q)")
	return 1
}

# ---------------------------------------------------------------- npm
setup_npm() {
	if ! have npm; then
		echo "npm topilmadi. Avval Node.js o'rnating (masalan: sudo apt install nodejs npm)."
		return 1
	fi
	local prefix
	prefix="$(npm config get prefix)"
	if [ ! -w "$prefix" ]; then
		echo "  npm prefix ($prefix) yozib bo'lmaydi, ~/.local ga o'zgartirilmoqda"
		npm config set prefix "$HOME/.local"
	fi
}

npm_pkg() { # npm_pkg <binary> <paket...>
	local bin="$1"
	shift
	run "$*" "$bin" npm install -g "$@"
}

# ---------------------------------------------------------------- GitHub
latest_tag() { # latest_tag <owner/repo>
	local json
	json="$(curl -fsSL "https://api.github.com/repos/$1/releases/latest")" || {
		echo "  [!] GitHub API javob bermadi (rate limit bo'lishi mumkin)" >&2
		return 1
	}
	printf '%s\n' "$json" | sed -n -E 's/.*"tag_name": *"([^"]+)".*/\1/p' | head -n1
}

install_lua_ls() {
	local tag ver dir tmp
	tag="$(latest_tag LuaLS/lua-language-server)" || return 1
	[ -n "$tag" ] || return 1
	ver="${tag#v}"
	dir="$SHARE_DIR/lua-language-server"
	tmp="$(mktemp -d)"
	curl -fsSL "https://github.com/LuaLS/lua-language-server/releases/download/${tag}/lua-language-server-${ver}-linux-x64.tar.gz" \
		-o "$tmp/lls.tar.gz" || return 1
	rm -rf "$dir"
	mkdir -p "$dir"
	tar -xzf "$tmp/lls.tar.gz" -C "$dir" || return 1
	rm -rf "$tmp"
	cat >"$BIN_DIR/lua-language-server" <<EOF
#!/usr/bin/env bash
exec "$dir/bin/lua-language-server" "\$@"
EOF
	chmod +x "$BIN_DIR/lua-language-server"
}

install_marksman() {
	curl -fsSL "https://github.com/artempyanykh/marksman/releases/latest/download/marksman-linux-x64" \
		-o "$BIN_DIR/marksman" && chmod +x "$BIN_DIR/marksman"
}

install_stylua() {
	need unzip stylua || return 1
	local tmp
	tmp="$(mktemp -d)"
	curl -fsSL "https://github.com/JohnnyMorganz/StyLua/releases/latest/download/stylua-linux-x86_64.zip" \
		-o "$tmp/stylua.zip" || return 1
	unzip -qo "$tmp/stylua.zip" -d "$tmp" || return 1
	install -m 755 "$tmp/stylua" "$BIN_DIR/stylua"
	rm -rf "$tmp"
}

# ================================================================ LSP
if [ "$DO_LSP" = 1 ]; then
	log "LSP serverlar"

	if setup_npm; then
		npm_pkg typescript-language-server typescript typescript-language-server
		npm_pkg vscode-css-language-server vscode-langservers-extracted # html, css, json, eslint
		npm_pkg tailwindcss-language-server @tailwindcss/language-server
		npm_pkg intelephense intelephense
		npm_pkg yaml-language-server yaml-language-server
		npm_pkg docker-langserver dockerfile-language-server-nodejs
	else
		FAILED+=("npm LSPlar (npm yo'q)")
	fi

	if have go; then
		run gopls gopls go install golang.org/x/tools/gopls@latest
		run sqls sqls go install github.com/sqls-server/sqls@latest
	else
		echo "  [!] go topilmadi: gopls, sqls o'tkazib yuborildi (sudo apt install golang)"
		FAILED+=("gopls, sqls (go yo'q)")
	fi

	if have rustup; then
		if have rust-analyzer; then
			echo "  [bor] rust-analyzer"
			SKIPPED+=("rust-analyzer")
		else
			echo "  [o'rnatilmoqda] rust-analyzer"
			rustup component add rust-analyzer && OK+=("rust-analyzer") || FAILED+=("rust-analyzer")
		fi
	else
		echo "  [!] rustup topilmadi: rust-analyzer o'tkazib yuborildi (https://rustup.rs)"
		FAILED+=("rust-analyzer (rustup yo'q)")
	fi

	run lua-language-server lua-language-server install_lua_ls
	run marksman marksman install_marksman
fi

# ================================================================ Formatterlar
if [ "$DO_FMT" = 1 ]; then
	log "Formatterlar (conform)"

	if setup_npm; then
		npm_pkg prettier prettier
		npm_pkg blade-formatter blade-formatter
	else
		FAILED+=("prettier, blade-formatter (npm yo'q)")
	fi

	if have go; then
		run shfmt shfmt go install mvdan.cc/sh/v3/cmd/shfmt@latest
		run gofumpt gofumpt go install mvdan.cc/gofumpt@latest
	else
		echo "  [!] go topilmadi: shfmt, gofumpt o'tkazib yuborildi"
		FAILED+=("shfmt, gofumpt (go yo'q)")
	fi

	run stylua stylua install_stylua

	if have rustup; then
		if have rustfmt; then
			echo "  [bor] rustfmt"
			SKIPPED+=("rustfmt")
		else
			echo "  [o'rnatilmoqda] rustfmt"
			rustup component add rustfmt && OK+=("rustfmt") || FAILED+=("rustfmt")
		fi
	else
		FAILED+=("rustfmt (rustup yo'q)")
	fi

	if have pipx; then
		run ruff ruff pipx install ruff
		run sqlfmt sqlfmt pipx install shandy-sqlfmt
	elif have uv; then
		run ruff ruff uv tool install ruff
		run sqlfmt sqlfmt uv tool install shandy-sqlfmt
	else
		echo "  [!] pipx/uv topilmadi: ruff, sqlfmt o'tkazib yuborildi (sudo apt install pipx)"
		FAILED+=("ruff, sqlfmt (pipx/uv yo'q)")
	fi

	# pint: Laravel loyihasida odatda vendor/bin/pint bo'ladi.
	# Global versiya faqat composer bo'lsa o'rnatiladi.
	if have pint || [ -x "$HOME/.config/composer/vendor/bin/pint" ] || [ -x "$HOME/.composer/vendor/bin/pint" ]; then
		echo "  [bor] pint"
		SKIPPED+=("pint")
	elif have composer; then
		echo "  [o'rnatilmoqda] pint (global)"
		composer global require laravel/pint && OK+=("pint") || FAILED+=("pint")
		echo "  Eslatma: ~/.config/composer/vendor/bin ni PATH ga qo'shing."
	else
		echo "  [!] composer topilmadi: pint o'tkazib yuborildi (loyihadagi vendor/bin/pint ham ishlaydi)"
		FAILED+=("pint (composer yo'q)")
	fi
fi

# ================================================================ Xulosa
log "Xulosa"
[ ${#OK[@]} -gt 0 ] && printf '  O'\''rnatildi : %s\n' "${OK[*]}"
[ ${#SKIPPED[@]} -gt 0 ] && printf '  Avvaldan bor: %s\n' "${SKIPPED[*]}"
[ ${#FAILED[@]} -gt 0 ] && printf '  \033[1;31mMuvaffaqiyatsiz: %s\033[0m\n' "${FAILED[*]}"

if ! grep -qs '\.local/bin' "$HOME/.zshenv" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bashrc" 2>/dev/null; then
	echo
	echo "PATH ga qo'shing (masalan ~/.zshenv yoki ~/.profile):"
	echo "  export PATH=\"\$HOME/.local/bin:\$HOME/.cargo/bin:\$PATH\""
fi

echo
echo "Tekshirish: nvim ichida  :checkhealth vim.lsp  va  :ConformInfo"

[ ${#FAILED[@]} -eq 0 ]
