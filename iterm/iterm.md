# Configuring iterm2

## Jump Between Words

The most annoying thing about iterm2 is the jumping between words feature. This
[post](https://coderwall.com/p/h6yfda/use-and-to-jump-forwards-backwards-words-in-iterm-2-on-os-x)
here explains it pretty well.

## Load Profile

`Preferences` > `Profiles` > `Other Actions` > `Import JSON Profiles...`
Then select `arshan_iterm_profile.json`. That'll fix the jumping between words
while holding `option` key.

Then make Arshan's profile the default.

`Preferences` > `Profiles` > `Other Actions` > `Set as Default`

## Loading Key Bindings

`Preferences` > `Keys` > `Presets...` > `Import...`
Then select `arshan_iterm_key_bindings.itermkeymap`.

This'll enable tab swiching.

## Disabling `option+Right` & `option+Left` 

**Update:** I realized I had set `option+Left` & `option+Right` above, to jump between words.
I'm not gonna disable this anymore because I've already remapped vim navigation for screen
resizes anyways.

I use this whenever I'm using tmux to resize panes left & right.

`Preferences` > `Profiles` > `Keys` > `Key Mappings` 

<img width="1128" alt="image" src="https://github.com/ArshanKhanifar/arshans_system_setup/assets/10492324/5533fadf-4869-473d-92a6-7a55ba164491">

