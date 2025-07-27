# CoC.nvim Examples & Usage Guide

## Installation

After updating vim plugins with `:PlugInstall`, CoC extensions will auto-install based on the languages you use.

## Key Bindings Reference

| Key | Action | Example |
|-----|--------|---------|
| `gd` | Go to definition | Jump to where a function is defined |
| `gy` | Go to type definition | See the type/interface definition |
| `gi` | Go to implementation | Find where interface is implemented |
| `gr` | Find references | See all places using this symbol |
| `K` | Show documentation | View function docs in popup |
| `[c` / `]c` | Previous/Next diagnostic | Navigate errors/warnings |
| `<leader>rn` | Rename symbol | Rename across entire project |
| `<leader>ca` | Code actions | Quick fixes and refactoring |
| `<leader>f` | Format selection | Auto-format code |
| `<leader>qf` | Quick fix | Auto-fix current line |
| `<leader>d` | Show documentation | Alternative to K |
| `<Tab>` | Next completion | Navigate suggestions |
| `<CR>` | Accept completion | Confirm selected suggestion |

## Language-Specific Examples

### Python

```python
# 1. Auto-completion
import requ|  # Press Tab → suggests 'requests'

# 2. Type information
def calculate(x: int, y: int) -> int:
    return x + y

result = calculate(10, 20)  # Hover with K shows: "(x: int, y: int) -> int"

# 3. Go to definition (gd)
from mymodule import helper_function
helper_function()  # Press gd → jumps to mymodule.py

# 4. Find all references (gr)
my_variable = 42  # Press gr → shows all uses of my_variable

# 5. Quick fixes (<leader>ca)
undefined_func()  # Shows: "Import 'undefined_func' from module"

# 6. Auto-imports
Path(|)  # Type and accept → adds "from pathlib import Path"
```

### JavaScript/TypeScript

```javascript
// 1. Auto-import on completion
const data = fetchData|  // Tab → completes and adds import

// 2. Type checking
const num: number = "string"  // Red underline, [g to see error

// 3. Rename symbol (<leader>rn)
const oldName = 5;  // Rename to 'newName' everywhere

// 4. Extract to function (<leader>ca)
// Select code block → Extract to function/variable

// 5. Organize imports (:OR)
import { b, a } from './utils';  // :OR → sorts imports

// 6. JSDoc completion
/**
 * @par|  // Completes to @param
 */
```

### Rust

```rust
// 1. Type inference
let mut vec = Vec::new();
vec.push(42);  // K shows: Vec<i32>

// 2. Error explanations
let x: &str = 123;  // Hover shows detailed error

// 3. Auto-derive
#[derive(|)]  // Suggests: Debug, Clone, PartialEq, etc.

// 4. Import suggestions
HashMap::new()  // <leader>ca → Import HashMap

// 5. Inline hints
// Shows parameter names and types inline
```

### YAML (Docker, K8s)

```yaml
# 1. Schema validation
apiVersion: apps/v1
kind: Deployment
spec:
  replicas: "three"  # Error: should be number

# 2. Auto-completion
image: |  # Suggests from Docker Hub

# 3. Hover documentation
command: |  # K shows field documentation
```

### Shell/Bash

```bash
# 1. Shellcheck integration
if [ $var == "test" ]  # Warning: use [[ ]] or quote $var

# 2. Command completion
git che|  # Suggests: checkout, cherry-pick

# 3. Variable tracking
MY_VAR="hello"
echo $MY_V|  # Completes to MY_VAR
```

## Common Workflows

### 1. Fix All Errors in File
```vim
:CocDiagnostics   " See all problems
[g                " Go to first error
<leader>qf        " Quick fix
]g                " Next error
<leader>qf        " Fix it
" Repeat...
```

### 2. Refactor a Function
```vim
" 1. Place cursor on function name
" 2. <leader>rn to rename
" 3. Type new name
" 4. Enter to apply everywhere
```

### 3. Add Missing Imports
```vim
:OR              " Organize and add imports
" or
<leader>ca       " On undefined symbol
```

### 4. Format on Save
```vim
:w               " Automatically formats supported files
" or manually:
:Format          " Format entire file
```

### 5. Jump Through Code
```vim
gd               " Go to definition
<C-o>            " Jump back
gr               " Find all usages
<C-]>            " Follow tag
```

## Troubleshooting

### Check CoC Status
```vim
:CocInfo         " See CoC status and logs
:CocList extensions  " Manage extensions
:checkhealth     " Overall vim health
```

### Install Missing Language Servers
```vim
:CocInstall coc-python     " Python
:CocInstall coc-tsserver   " JS/TS
:CocInstall coc-rust-analyzer  " Rust
```

### Common Issues

1. **No completions appearing**
   - Check `:CocInfo` for errors
   - Ensure language server is installed
   - Try `:CocRestart`

2. **Slow performance**
   - Exclude large folders in coc-settings.json
   - Disable unused extensions

3. **Format on save not working**
   - Check file type is in `formatOnSaveFiletypes`
   - Install formatter (prettier, black, etc.)

## Tips

- Use `:CocCommand` to see all available commands
- `<leader>` is typically `\` unless remapped
- CoC works best with vim 8.1+ or neovim
- Language servers need to be installed separately (npm, pip, etc.)