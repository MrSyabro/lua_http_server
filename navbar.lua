local h = require "html"

local menu = {
    {
        href = "index",
        text = "Home",
    },
    {
        href = "forms.lua",
        text = "Forms"
    },
    {
        href = "dump-headers",
        text = "Dump headers"
    },
    {
        href = "files",
        text = "Files"
    },
    {
        href = "payload",
        text = "Payload test"
    }
}

local function genmenu()
    local out = {}
    for _, el in ipairs(menu) do
        table.insert(out, h.li({class="nav-item"},
            h.a({class="nav-link active", ["aria-current"]="page", href=el.href}, el.text)
        ))
    end
    return table.concat(out)
end

local head = h.nav({class="navbar navbar-expand-lg bg-body-tertiary"},
    h.div({class="container-fluid"},
        h.a({class="navbar-brand", href="index"}, "Navbar"),
        h.button( { class="navbar-toggler", type="button", ["data-bs-toggle"]="collapse", ["data-bs-target"]="#navbarNav", ["aria-controls"]="navbarNav", ["aria-expanded"]="false", ["aria-label"]="Toggle navigation"},
            h.span { class="navbar-toggler-icon" }
        ),
        h.div({class="collapse navbar-collapse", id="navbarNav"},
            h.ul({class="navbar-nav"}, genmenu())
        )
    )
)

return head