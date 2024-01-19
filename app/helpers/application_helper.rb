module ApplicationHelper
    include Pagy::Frontend

    def change_action(action)
        if action == "CNAME ."
            return "NXDOMAIN"
        elsif action == "CNAME *."
            return "NODATA"
        elsif action == "CNAME rpz-passthru."
            return "PASSTHRU" 
        elsif action == "CNAME rpz-drop."
            return "DROP"
        elsif action == "CNAME rpz-tcp-only."
            return "TCP-ONLY"
        elsif action == "CNAME"
            return "CNAME"
        elsif action == "A"
            return "A"
        elsif action == "AAA"
            return "AAA"
        else
            return "no action"
        end
    end
end
