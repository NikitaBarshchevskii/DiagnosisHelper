using CImGui
using ImPlot
using JSON
using CImGui.CSyntax
using CImGui.CSyntax.CStatic
using CImGui: ImVec2
using Gtk

include(joinpath(pathof(ImPlot),"..","..","demo","Renderer.jl"))
using .Renderer

mutable struct Vars
    filename::String
    data::Dict{String, Any}
    newname::String
    newdiagnosis::String
    newban::String
    is_file_loaded::Bool

    function Vars()
        filename = ""
        data = Dict("" => "")
        newname = ""
        newdiagnosis = ""
        newban = ""
        is_file_loaded = false

        new(filename, data, newname, newdiagnosis, newban, is_file_loaded)
    end
end

function ui(v::Vars)

    CImGui.Begin("Rewrite json")

        if CImGui.Button("Load file.json")
            v.filename = open_dialog_native("Select file", GtkNullContainer(), ("*.json",))
            if v.filename != ""
                v.data = JSON.parsefile(v.filename)
                v.is_file_loaded = true
            else
                warn_dialog("File was not selected!")
                v.is_file_loaded = false
            end
        end

        if v.is_file_loaded
            @cstatic str0="New group name"*"\0"^50 begin
                CImGui.InputText("Group name", str0, length(str0))
                v.newname = replace(str0 ,"\0" => "")
            end

            @cstatic str1 = "New phrase"*"\0"^50 begin
                CImGui.InputText("Phrase", str1, length(str1))
                v.newdiagnosis = replace(str1 ,"\0" => "")
            end

            @cstatic str2 = "New banned combination"*"\0"^50 begin
                CImGui.InputText("Banned combination", str2, length(str2))
                v.newban = replace(str2 ,"\0" => "")
            end

            if CImGui.Button("Add changes to file.json")
                can_whrite = true
                # сделать возможность добавления вектора из забаненных фраз!!!!!!!!!!!
                if v.newname != "" && v.newdiagnosis != "" && v.newban != "" 

                    names = v.data["groupnames"]
                    is_new=true

                    for i in 1:length(names)
                        if v.newname == names[i]
                            is_new = false
                        end
                    end

                    if is_new
                        entry = Dict(v.newname => ([Dict("diagnosis" => v.newdiagnosis, "ban" => v.newban)]))
                        newdata = merge(v.data, entry)
                        push!(newdata["groupnames"], v.newname)
                    else
                        newdata = v.data
                        group = newdata[v.newname]

                        is_new_diagnosis = true
                        for i in 1:length(group)
                            if group[i]["diagnosis"] == v.newdiagnosis
                                is_new_diagnosis = false
                            end
                        end

                        if is_new_diagnosis
                            push!(newdata[v.newname], Dict("diagnosis" => v.newdiagnosis, "ban" => v.newban))
                        else
                            warn_dialog("The entered phrase is already in this section")
                            can_whrite = false
                        end
                    end

                    if can_whrite
                        open(v.filename,"w") do f
                            JSON.print(f, newdata)
                        end
                    end

                    info_dialog("Changes were added")

                end
            end
        end

    CImGui.End()

    # newname = "new entry"
    # newdiagnosis = "d3"
    # newban = [""]

    # names = data["groupnames"]

    # # data[newname]

    # is_new=true
    # for i in 1:length(names)
    #     if newname == names[i]
    #         is_new = false
    #     end
    # end

    # if is_new
    #     entry=Dict(newname => ([Dict("diagnosis" => newdiagnosis, "ban" => newban)]))
    #     newdata = merge(data, entry)
    #     push!(newdata["groupnames"], newname)
    # else
    #     newdata = data
    #     group = newdata[newname]

    #     is_new_diagnosis = true
    #     for i in 1:length(group)
    #         if group[i]["diagnosis"] == newdiagnosis
    #             is_new_diagnosis = false
    #         end
    #     end

    #     if is_new_diagnosis
    #         push!(newdata[newname], Dict("diagnosis" => newdiagnosis, "ban" => newban))
    #     else
    #         # вывести сообщение о том, что такая фраза в этом разделе уже соержится
    #     end
    # end

    # open(s,"w") do f
    #     JSON.print(f, newdata)
    # end

end

function show_gui()
    state = Vars()
    Renderer.render(
        ()->ui(state),
        width=1600,
        height=700,
        title="",
        hotloading=true
    )
    return state
end

show_gui();