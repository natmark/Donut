import Foundation
import Commandant
import DonutKit

let registry = CommandRegistry<DonutError>()
registry.register(VersionCommand())
registry.register(ListCommand())

let helpCommand = HelpCommand(registry: registry)
registry.register(helpCommand)

registry.main(defaultVerb: helpCommand.verb) { error in
    fputs(error.localizedDescription + "\n", stderr)
}
