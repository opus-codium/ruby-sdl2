require 'sdl2'

SDL2.init(SDL2::INIT_HAPTIC)

direction = SDL2::HapticDirection.new
direction.type = SDL2::HAPTIC_CARTESIAN
puts direction.dir.inspect
direction.dir[0] = 0
direction.dir[1] = 1
puts direction.dir.inspect
direction.dir = [1, 0]
puts direction.dir.inspect

effect = SDL2::HapticEffect.new
e2 = SDL2::HapticEffect.new
puts effect.type.inspect
puts e2.type.inspect
effect.type = SDL2::HAPTIC_SINE
puts effect.type.inspect
puts e2.type.inspect
