using CImGui
using ImPlot
using JSON
using CImGui.CSyntax
using CImGui.CSyntax.CStatic
using CImGui: ImVec2
using Gtk

include(joinpath(pathof(ImPlot),"..","..","demo","Renderer.jl"))
using .Renderer

# include(joinpath(pathof(CImGui), "..", "..", "demo", "demo.jl"))

mutable struct Vars
    file::String
    data::Dict{String, Any}
    names::Vector{Any}
    check::Vector{Int64}
    test::Vector{Int64}
    conclusion::String
    
    function Vars()
        file = "configs/configENG.json"
        data = JSON.parsefile(file)
        names = data["groupnames"]
        check = fill(0,length(names))
        test = [0]
        conclusion = ""

        new(file, data, names, check, test, conclusion)
    end
end

function ui(v::Vars)
    CImGui.Begin("Menu")
        if CImGui.TreeNode(v.names[1])
            groupdata=v.data[v.names[1]]
            for j in 1:length(groupdata)
                CImGui.RadioButton(groupdata[j], v.check[1] == j) && (v.check[1] = j;)
            end
        end

        if v.check[1]!=0
            for i in 2:length(v.names)
                if CImGui.TreeNode(v.names[i])
                    groupdata=v.data[v.names[i]]
                    for j in 1:length(groupdata)
                        CImGui.RadioButton(groupdata[j], v.check[i] == j) && (v.check[i] = j;)
                    end
                end
            end
        end

        # CImGui.RadioButton("test1", v.test[1] == 10) && (v.test[1] = 10;)
        # CImGui.RadioButton("test2", v.test[1] == 11) && (v.test[1] = 11;)
        # CImGui.RadioButton("test3", v.test[1] == 12) && (v.test[1] = 12;)
    CImGui.End
    
    CImGui.Begin("Conclusion")
        CImGui.SameLine(600)
        if CImGui.Button("Save conclusion")
            fname=save_dialog_native("Select file", GtkNullContainer(), ("*.doc",))
            write(fname,v.conclusion)
        end

        @cstatic read_only=false (text="\0"^(1024*16-249)) begin
            flags = CImGui.ImGuiInputTextFlags_AllowTabInput
            txt=" "
            for i in 1:length(v.names)
                if v.check[i]!=0
                    txt*=v.data[v.names[i]][v.check[i]]*". "
                end
            end
            CImGui.InputTextMultiline("##source", txt*text, length(text), ImVec2(-1.0, CImGui.GetTextLineHeight() * 16), flags)

            v.conclusion=txt
        end
    CImGui.End
end

function show_gui()
    state = Vars()
    Renderer.render(
        ()->ui(state),
        width=850,
        height=700,
        title="",
        hotloading=true
    )
    return state
end

show_gui()