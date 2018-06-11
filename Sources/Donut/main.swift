import Foundation
import Commandant
import DonutKit

guard Git.ensureGitVersion().first()?.value == true else {
    fputs("Donut requires git \(Git.donutRequiredGitVersion) or later.\n", stderr)
    exit(EXIT_FAILURE)
}

let registry = CommandRegistry<DonutError>()
registry.register(VersionCommand())
registry.register(ListCommand())
registry.register(InstallCommand())
registry.register(RemoveCommand())

let helpCommand = HelpCommand(registry: registry)
registry.register(helpCommand)

registry.main(defaultVerb: helpCommand.verb) { error in
    fputs(error.localizedDescription + "\n", stderr)
}
