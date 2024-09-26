start_zone = {

    path = 
    {
        text = zones_path.."Start/Texts/",
        -- dialog = primary_quest_path.."AshaTear/Dialogs/"
    },

    Init = 
    function ()
        Touch.DisableObject("start_zone_elf_treasure")
        Touch.SetFunction("start_zone_elf_treasure", "default", start_zone.TreantBankDefault)
    end,

    -- дефолтная функция касания - вызывается только если есть только она 
    TreantBankDefault =
    function (hero, object)
        if not (Touch.GetHandlersCount(object) == 1 and Touch.HasFunction(object, "default")) then
            return
        end
        MessageBox(start_zone.path.text.."treant_bank_default.txt")
    end,
}