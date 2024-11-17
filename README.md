# dart-snippets.nvim

A Neovim plugin that streamlines Dart development by automatically generating data classes with common boilerplate code.

## Features

- Support for common data class operations:
  - copyWith method
  - Map conversion
  - JSON serialization/deserialization
  - toString override
  - hashCode implementation
  - Equality operators
  - Equatable Property setters

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "IniyanKanmani/dart-snippets.nvim",
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use "IniyanKanmani/dart-snippets.nvim"
```

## Default Options

```lua
require("dart_snippets").setup({
    data_class = {
        copy_with = true,
        to_map = true,
        from_map = true,
        to_json = true,
        from_json = true,
        to_string = true,
        hash_code = true,
        operator = true,
        props = true,
    },
})
```

## Usage

### Commands

- `:GenerateDartDataClass` - Generate a data class with all configured options

## Support

If you encounter any issues or have questions, please feel free to:

- Open an issue on GitHub
- Submit a pull request

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## Acknowledgments

This plugin was created as a learning project to understand Neovim plugin development

⭐ If you find this plugin helpful, consider giving it a star on GitHub!
