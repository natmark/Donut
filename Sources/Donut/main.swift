import Foundation
import Commandant
import DonutKit

guard ensureGitVersion().first()?.value == true else {
    fputs("Donut requires git \(donutRequiredGitVersion) or later.\n", stderr)
    exit(EXIT_FAILURE)
}

let registry = CommandRegistry<DonutError>()
registry.register(VersionCommand())
registry.register(ListCommand())

let helpCommand = HelpCommand(registry: registry)
registry.register(helpCommand)

registry.main(defaultVerb: helpCommand.verb) { error in
    fputs(error.localizedDescription + "\n", stderr)
}
