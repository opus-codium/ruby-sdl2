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

static VALUE cHapticEffect;

typedef struct HapticEffect {
    SDL_HapticEffect *haptic_effect;
} HapticEffect;

#if 0
static void HapticEffect_free(HapticEffect *effect)
{
    free(effect);
}

static VALUE HapticEffect_new(SDL_HapticEffect *effect)
{
    printf("===> HapticEffect_new\n");
    HapticEffect *e = ALLOC(HapticEffect);
    e->haptic_effect = effect;
    return Data_Wrap_Struct(cHapticEffect, 0, HapticEffect_free, e);
}
#endif

DEFINE_WRAPPER(SDL_HapticEffect, HapticEffect, haptic_effect, cHapticEffect, "SDL2::HapticEffect");

static VALUE cHapticConstant;

typedef struct HapticConstant {
    SDL_HapticConstant *haptic_constant;
} HapticConstant;

static VALUE HapticConstant_new(SDL_HapticConstant *constant)
{
    HapticConstant *c = ALLOC(HapticConstant);
    c->haptic_constant = constant;
    return Data_Wrap_Struct(cHapticConstant, 0, free, c);
}

DEFINE_WRAPPER(SDL_HapticConstant, HapticConstant, haptic_constant, cHapticConstant, "SDL2::HapticConstant");

static VALUE Haptic_s_name(VALUE self, VALUE device_index)
{
    const char *name = SDL_HapticName(NUM2INT(device_index));
    if (!name)
        SDL_ERROR();
    return rb_str_new_cstr(name);
}

static VALUE Haptic_s_open(VALUE self, VALUE device_index)
{
    SDL_Haptic *haptic = SDL_HapticOpen(NUM2INT(device_index));
    if (!haptic)
        SDL_ERROR();
    return Haptic_new(haptic);
}

static VALUE Haptic_s_opened(VALUE self, VALUE device_index)
{
    return INT2NUM(HANDLE_ERROR(SDL_HapticOpened(NUM2INT(device_index))));
}

static VALUE Haptic_s_open_from_joystick(VALUE self, VALUE joystick)
{
    SDL_Joystick *j = rubysdl2_get_joystick(joystick);

    SDL_Haptic *haptic = SDL_HapticOpenFromJoystick(j);
    if (!haptic)
        SDL_ERROR();
    return Haptic_new(haptic);
}

static VALUE Haptic_s_open_from_mouse(VALUE self)
{
    SDL_Haptic *haptic = SDL_HapticOpenFromMouse();
    if (!haptic)
        SDL_ERROR();
    return Haptic_new(haptic);
}

static VALUE Haptic_index(VALUE self)
{
    return INT2NUM(HANDLE_ERROR(SDL_HapticIndex(Get_SDL_Haptic(self))));
}

static VALUE Haptic_num_axes(VALUE self)
{
    return INT2NUM(HANDLE_ERROR(SDL_HapticNumAxes(Get_SDL_Haptic(self))));
}

static VALUE Haptic_num_effects(VALUE self)
{
    return INT2NUM(HANDLE_ERROR(SDL_HapticNumEffects(Get_SDL_Haptic(self))));
}

static VALUE Haptic_num_effects_playing(VALUE self)
{
    return INT2NUM(HANDLE_ERROR(SDL_HapticNumEffectsPlaying(Get_SDL_Haptic(self))));
}

static VALUE Haptic_pause(VALUE self)
{
    return INT2NUM(HANDLE_ERROR(SDL_HapticPause(Get_SDL_Haptic(self))));
}

static VALUE Haptic_query(VALUE self)
{
    return INT2NUM(HANDLE_ERROR(SDL_HapticQuery(Get_SDL_Haptic(self))));
}

static VALUE Haptic_set_autocenter(VALUE self, VALUE autocenter)
{
    return INT2NUM(HANDLE_ERROR(SDL_HapticSetAutocenter(Get_SDL_Haptic(self), INT2NUM(autocenter))));
}

static VALUE Haptic_set_gain(VALUE self, VALUE gain)
{
    return INT2NUM(HANDLE_ERROR(SDL_HapticSetGain(Get_SDL_Haptic(self), INT2NUM(gain))));
}

static VALUE Haptic_stop_all(VALUE self)
{
    return INT2NUM(HANDLE_ERROR(SDL_HapticStopAll(Get_SDL_Haptic(self))));
}

static VALUE Haptic_unpause(VALUE self)
{
    return INT2NUM(HANDLE_ERROR(SDL_HapticUnpause(Get_SDL_Haptic(self))));
}

//

static VALUE HapticEffect_new(SDL_HapticEffect *effect)
{
    printf("===> HapticEffect_new\n");
    HapticEffect *e = ALLOC(HapticEffect);
    e->haptic_effect = ALLOC(SDL_HapticEffect);
    return Data_Wrap_Struct(cHapticEffect, 0, free, e);
}

static VALUE HapticEffect_s_new(int argc, VALUE *argv, VALUE self)
{
    printf("===> HapticEffect_s_new\n");
    SDL_HapticEffect *effect;
    return HapticEffect_new(effect);
}

static VALUE HapticEffect_get_type(VALUE self)
{
    printf("===> HapticEffect_get_type\n");
    int res = Get_SDL_HapticEffect(self)->type;
    printf("    %d\n", res);
    return INT2NUM(Get_SDL_HapticEffect(self)->type);
}

static VALUE HapticEffect_set_type(VALUE self, VALUE type)
{
    SDL_HapticEffect *effect = Get_SDL_HapticEffect(self);
    effect->type = NUM2INT(type);
    return type;
}

void rubysdl2_init_haptic(void)
{
    cHaptic = rb_define_class_under(mSDL2, "Haptic", rb_cObject);

    rb_define_singleton_method(cHaptic, "name", Haptic_s_name, 1);
    rb_define_singleton_method(cHaptic, "open", Haptic_s_open, 1);
    rb_define_singleton_method(cHaptic, "opened", Haptic_s_opened, 1);
    rb_define_singleton_method(cHaptic, "open_from_joystick", Haptic_s_open_from_joystick, 1);
    rb_define_singleton_method(cHaptic, "open_from_mouse", Haptic_s_open_from_mouse, 0);

    rb_define_method(cHaptic, "index", Haptic_index, 0);
    rb_define_method(cHaptic, "num_axes", Haptic_num_axes, 0);
    rb_define_method(cHaptic, "num_effects", Haptic_num_effects, 0);
    rb_define_method(cHaptic, "num_effects_playing", Haptic_num_effects_playing, 0);
    rb_define_method(cHaptic, "pause", Haptic_pause, 0);
    rb_define_method(cHaptic, "query", Haptic_query, 0);
    rb_define_method(cHaptic, "set_autocenter", Haptic_set_autocenter, 1);
    rb_define_method(cHaptic, "set_gain", Haptic_set_gain, 1);
    rb_define_method(cHaptic, "stop_all", Haptic_stop_all, 0);
    rb_define_method(cHaptic, "unpause", Haptic_unpause, 0);

    cHapticEffect = rb_define_class_under(mSDL2, "HapticEffect", rb_cObject);

    rb_undef_alloc_func(cHapticEffect);
    rb_define_singleton_method(cHapticEffect, "new", HapticEffect_s_new, -1);
    rb_define_method(cHapticEffect, "type", HapticEffect_get_type, 0);
    rb_define_method(cHapticEffect, "type=", HapticEffect_set_type, 1);

    cHapticConstant = rb_define_class_under(mSDL2, "HapticConstant", rb_cObject);
}
