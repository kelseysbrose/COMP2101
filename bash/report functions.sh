Kelsey Rose 

# Function for saving timestame error message 
function errormessage() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local error_message="$1"
    echo "[$timestamp] $error_message" >> /var/log/systeminfo.log
    echo "$error_message" >&2
}
function cpureport() {
cat <<EOF
CPU Info
------------
