// vim:filetype=c:
#include "rubysdl2_internal.h"
#include <SDL_haptic.h>

#include "joystick.h"

static VALUE cHaptic;

typedef struct Haptic {
    SDL_Haptic *haptic;
} Haptic;

static void Haptic_free(Haptic *h)
{
    if (rubysdl2_is_active() && h->haptic)
        SDL_HapticClose(h->haptic);
    free(h);
}

static VALUE Haptic_new(SDL_Haptic *haptic)
{
    Haptic *h = ALLOC(Haptic);
    h->haptic = haptic;
    return Data_Wrap_Struct(cHaptic, 0, Haptic_free, h);
}

DEFINE_WRAPPER(SDL_Haptic, Haptic, haptic, cHaptic, "SDL2::Haptic");

static VALUE Haptic_s_open(VALUE self, VALUE device_index)
{
    SDL_Haptic *haptic = SDL_HapticOpen(NUM2INT(device_index));
    if (!haptic)
        SDL_ERROR();
    return Haptic_new(haptic);
}

static VALUE Haptic_s_open_from_joystick(VALUE self, VALUE joystick)
{
    SDL_Joystick *j = rubysdl2_get_joystick(joystick);

    SDL_Haptic *haptic = SDL_HapticOpenFromJoystick(j);
    if (!haptic)
        SDL_ERROR();
    return Haptic_new(haptic);
}

void rubysdl2_init_haptic(void)
{
    cHaptic = rb_define_class_under(mSDL2, "Haptic", rb_cObject);
    rb_define_singleton_method(cHaptic, "open", Haptic_s_open, 1);
    rb_define_singleton_method(cHaptic, "open_from_joystick", Haptic_s_open_from_joystick, 1);
}
