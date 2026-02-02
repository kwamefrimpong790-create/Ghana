#!/data/data/com.termux/files/usr/bin/bash
# ============================================================================
# GHANA DECEPTION ENGINE v2.0
# Targeted reality manipulation for com.community.oneroom
# Single-file, persistent, zero-root surgical strike
# GitHub: https://github.com/yourusername/oneRoom-ghana-deception
# ============================================================================

set -e

# Configuration
TARGET_APP="com.community.oneroom"
GHANA_IP="41.204.0.100"
GHANA_COORDS="5.6037,-0.1870"
DECEIT_ROOT="$HOME/.oneRoom_ghana"
LOG_DIR="$HOME/.ghana_logs"
BOOT_DIR="$HOME/.termux/boot"
PERSISTENCE_FILE="$DECEIT_ROOT/.enabled"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo -e "${PURPLE}"
cat << 'BANNER'
╔══════════════════════════════════════════════════════════╗
║   ██████  ██   ██  █████  ███    ██  █████              ║
║  ██       ██   ██ ██   ██ ████   ██ ██   ██             ║
║  ██   ███ ███████ ███████ ██ ██  ██ ███████             ║
║  ██    ██ ██   ██ ██   ██ ██  ██ ██ ██   ██             ║
║   ██████  ██   ██ ██   ██ ██   ████ ██   ██             ║
║                                                          ║
║  Targeted Reality Manipulation Engine v2.0               ║
║  Surgical Deception for: com.community.oneroom           ║
╚══════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"

# Functions
log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1" | tee -a "$LOG_DIR/engine.log"
}

success() {
    echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_DIR/engine.log"
}

warning() {
    echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_DIR/engine.log"
}

error() {
    echo -e "${RED}[✗]${NC} $1" | tee -a "$LOG_DIR/engine.log"
}

fatal() {
    error "$1"
    exit 1
}

check_dependencies() {
    log "Checking dependencies..."
    
    # Check essential packages
    for pkg in python nodejs; do
        if ! command -v $pkg >/dev/null 2>&1; then
            warning "$pkg not found. Installing..."
            pkg install $pkg -y >/dev/null 2>&1 || {
                error "Failed to install $pkg"
                return 1
            }
            success "Installed $pkg"
        fi
    done
    
    # Check Python modules
    if ! python -c "import faker" 2>/dev/null; then
        warning "Installing Python faker module..."
        pip install faker >/dev/null 2>&1 || {
            error "Failed to install faker"
            return 1
        }
        success "Installed faker module"
    fi
    
    # Check Node modules
    if [ ! -d "$HOME/node_modules/dns-packet" ]; then
        warning "Installing Node.js DNS module..."
        npm install dns-packet >/dev/null 2>&1 || {
            error "Failed to install DNS module"
            return 1
        }
        success "Installed DNS module"
    fi
    
    return 0
}

setup_environment() {
    log "Setting up deception environment..."
    
    # Create directories
    mkdir -p "$DECEIT_ROOT"/{dns,http,location,storage,bin}
    mkdir -p "$LOG_DIR"
    mkdir -p "$BOOT_DIR"
    
    # Create PID file directory
    mkdir -p "$DECEIT_ROOT/pids"
    
    success "Environment created"
}

create_dns_spoofer() {
    cat > "$DECEIT_ROOT/dns/spoofer.js" << 'DNSEOF'
const dgram = require('dgram');
const dnsPacket = require('dns-packet');
const fs = require('fs');

const GHANA_IP = '41.204.0.100';
const TARGET_DOMAINS = [
    'geo', 'location', 'region', 'ip-api', 'ipinfo',
    'oneroom', 'check', 'validate', 'country'
];
const LOG_FILE = process.env.HOME + '/.ghana_logs/dns.log';

function log(msg) {
    const timestamp = new Date().toISOString();
    fs.appendFileSync(LOG_FILE, `[${timestamp}] ${msg}\n`);
}

const server = dgram.createSocket('udp4');

server.on('message', (msg, rinfo) => {
    try {
        const packet = dnsPacket.decode(msg);
        
        if (packet.questions && packet.questions.length > 0) {
            const question = packet.questions[0];
            const domain = question.name.toLowerCase();
            
            // Check if domain is geo-related
            const isGeoDomain = TARGET_DOMAINS.some(keyword => domain.includes(keyword));
            
            if (isGeoDomain) {
                log(`Spoofing DNS: ${domain} -> ${GHANA_IP}`);
                
                const response = dnsPacket.encode({
                    type: 'response',
                    id: packet.id,
                    flags: dnsPacket.AUTHORITATIVE_ANSWER,
                    questions: packet.questions,
                    answers: [{
                        type: 'A',
                        class: 'IN',
                        name: domain,
                        ttl: 300,
                        data: GHANA_IP
                    }]
                });
                
                server.send(response, rinfo.port, rinfo.address);
                return;
            }
        }
        
        // Forward to real DNS (Google DNS)
        const forward = dgram.createSocket('udp4');
        forward.send(msg, 0, msg.length, 53, '8.8.8.8');
        
        forward.on('message', (response) => {
            server.send(response, rinfo.port, rinfo.address);
            forward.close();
        });
        
        forward.on('error', () => forward.close());
        
    } catch (err) {
        log(`DNS Error: ${err.message}`);
    }
});

server.on('listening', () => {
    const address = server.address();
    log(`DNS spoofer listening on ${address.address}:${address.port}`);
    console.log('[DNS] Ghana DNS spoofer active on port 5353');
});

server.on('error', (err) => {
    log(`DNS Server Error: ${err.message}`);
});

server.bind(5353, '127.0.0.1');

// Keep alive
process.on('SIGINT', () => process.exit(0));
process.on('SIGTERM', () => process.exit(0));
DNSEOF
    success "DNS spoofer created"
}

create_http_proxy() {
    cat > "$DECEIT_ROOT/http/proxy.py" << 'HTTPEOF'
#!/usr/bin/env python3
import sys
import socket
import threading
import time
import json
from datetime import datetime
from faker import Faker

fake = Faker()
GHANA_IPS = ['41.204.0.100', '41.204.1.100', '197.251.0.100']
LOG_FILE = '/data/data/com.termux/files/home/.ghana_logs/http.log'

def log(message):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    with open(LOG_FILE, 'a') as f:
        f.write(f'[{timestamp}] {message}\n')
    print(f'[HTTP] {message}')

def create_ghana_response():
    """Create fake API responses for geo-location checks"""
    responses = {
        'ip-api.com': {
            'status': 'success',
            'country': 'Ghana',
            'countryCode': 'GH',
            'region': 'AA',
            'regionName': 'Greater Accra',
            'city': 'Accra',
            'lat': 5.6037,
            'lon': -0.1870,
            'timezone': 'Africa/Accra',
            'isp': 'Ghana Telecom',
            'org': 'Ghana Communications',
            'as': 'AS37119 Ghana Telecom',
            'query': GHANA_IPS[0]
        },
        'ipinfo.io': {
            'ip': GHANA_IPS[0],
            'hostname': 'ghana.gh.telecom.net',
            'city': 'Accra',
            'region': 'Greater Accra',
            'country': 'GH',
            'loc': '5.6037,-0.1870',
            'org': 'AS37119 Ghana Telecom',
            'timezone': 'Africa/Accra'
        },
        'default': {
            'country': 'GH',
            'region_allowed': True,
            'timestamp': int(time.time())
        }
    }
    return responses

class GhanaProxy:
    def __init__(self):
        self.ghana_responses = create_ghana_response()
        self.ghana_headers = {
            'X-Forwarded-For': GHANA_IPS[0],
            'X-Real-IP': GHANA_IPS[0],
            'X-Geo-Country': 'GH',
            'X-Client-Region': 'Accra',
            'Accept-Language': 'en-GH,en;q=0.9',
            'X-Client-TimeZone': 'Africa/Accra',
            'User-Agent': 'Mozilla/5.0 (Linux; Android 13; Ghana) AppleWebKit/537.36'
        }
    
    def handle_client(self, client_socket):
        try:
            request = client_socket.recv(4096).decode('utf-8', errors='ignore')
            
            if not request:
                client_socket.close()
                return
            
            # Extract Host header
            host = None
            for line in request.split('\n'):
                if line.lower().startswith('host:'):
                    host = line.split(':', 1)[1].strip()
                    break
            
            # Check if this is a geo-location API call
            is_geo_request = any(geo in host for geo in ['ip-api', 'ipinfo', 'geo', 'location']) if host else False
            
            if is_geo_request:
                # Return fake Ghana location data
                domain = host.split(':')[0] if ':' in host else host
                response_data = self.ghana_responses.get(domain, self.ghana_responses['default'])
                
                response = f"""HTTP/1.1 200 OK
Content-Type: application/json
Access-Control-Allow-Origin: *
Connection: close
Content-Length: {len(json.dumps(response_data))}

{json.dumps(response_data, indent=2)}"""
                
                client_socket.send(response.replace('\n', '\r\n').encode())
                log(f"Spoofed geo-request to {host}")
                
            else:
                # Forward request with Ghana headers
                headers_end = request.find('\n\n')
                if headers_end == -1:
                    headers_end = request.find('\r\n\r\n')
                
                if headers_end != -1:
                    headers = request[:headers_end]
                    body = request[headers_end:]
                    
                    # Inject Ghana headers
                    for header, value in self.ghana_headers.items():
                        if header.lower() not in headers.lower():
                            headers += f"\n{header}: {value}"
                    
                    modified_request = headers + body
                    
                    # Forward to actual host (simplified - in production would actually connect)
                    log(f"Proxied request to {host} with Ghana headers")
                    response = f"""HTTP/1.1 200 OK
Content-Type: text/plain
Connection: close
Content-Length: 15

Proxied to {host}"""
                    
                    client_socket.send(response.replace('\n', '\r\n').encode())
            
        except Exception as e:
            log(f"Error: {str(e)}")
        finally:
            client_socket.close()
    
    def start(self, port=8080):
        server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server.bind(('0.0.0.0', port))
        server.listen(5)
        
        log(f"HTTP proxy listening on port {port}")
        
        while True:
            client, addr = server.accept()
            client_handler = threading.Thread(target=self.handle_client, args=(client,))
            client_handler.daemon = True
            client_handler.start()

if __name__ == '__main__':
    log("Starting Ghana HTTP proxy...")
    proxy = GhanaProxy()
    proxy.start(8080)
HTTPEOF
    success "HTTP proxy created"
}

create_location_feeder() {
    cat > "$DECEIT_ROOT/location/feeder.py" << 'LOCEOF'
#!/usr/bin/env python3
import os
import time
import json
from datetime import datetime
from faker import Faker

fake = Faker()
LOG_FILE = '/data/data/com.termux/files/home/.ghana_logs/location.log'
GHANA_COORDS = (5.6037, -0.1870)  # Accra, Ghana

def log(message):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    with open(LOG_FILE, 'a') as f:
        f.write(f'[{timestamp}] {message}\n')
    print(f'[LOCATION] {message}')

def create_location_data():
    """Generate realistic Ghana location data"""
    lat, lon = GHANA_COORDS
    # Add slight variations for realism
    lat += (fake.random.random() - 0.5) * 0.001
    lon += (fake.random.random() - 0.5) * 0.001
    
    return {
        'latitude': round(lat, 6),
        'longitude': round(lon, 6),
        'accuracy': round(fake.random.uniform(10, 30), 1),
        'altitude': round(fake.random.uniform(30, 50), 1),
        'speed': round(fake.random.uniform(0, 2), 1),
        'bearing': fake.random.randint(0, 360),
        'time': int(time.time() * 1000),
        'provider': fake.random.choice(['network', 'gps', 'fused']),
        'country_code': 'GH',
        'country_name': 'Ghana',
        'region': 'Greater Accra',
        'city': 'Accra',
        'address': fake.address().replace('\n', ', '),
        'postal_code': fake.postcode(),
        'isp': fake.random.choice(['Ghana Telecom', 'MTN Ghana', 'Vodafone Ghana']),
        'ip_address': f'41.204.{fake.random.randint(0,255)}.{fake.random.randint(1,254)}'
    }

def inject_through_adb(location_data):
    """Try to inject location via ADB commands"""
    try:
        # Method 1: Broadcast intent
        os.system(f'adb shell am broadcast -a android.intent.action.LOCATION_CHANGED '
                  f'--es latitude "{location_data["latitude"]}" '
                  f'--es longitude "{location_data["longitude"]}" '
                  f'--es provider "{location_data["provider"]}" '
                  f'--es accuracy "{location_data["accuracy"]}" '
                  f'2>/dev/null')
        
        # Method 2: Target specific app
        os.system(f'adb shell am broadcast -a com.community.oneroom.LOCATION_UPDATE '
                  f'--es country "GH" '
                  f'--es region "Greater Accra" '
                  f'--es city "Accra" '
                  f'--ef latitude {location_data["latitude"]} '
                  f'--ef longitude {location_data["longitude"]} '
                  f'2>/dev/null')
        
        # Method 3: Settings (if possible)
        os.system('adb shell settings put secure mock_location 1 2>/dev/null')
        
        return True
    except:
        return False

def write_location_files(location_data):
    """Write location data to files the app might read"""
    try:
        # Create in app-accessible locations
        locations = [
            '/storage/emulated/0/Android/data/com.community.oneroom/cache/location.json',
            '/storage/emulated/0/Android/media/com.community.oneroom/files/location.json',
            '/sdcard/Android/data/com.community.oneroom/cache/location.json',
            '/data/data/com.termux/files/home/.oneRoom_ghana/location/current.json'
        ]
        
        for loc_file in locations:
            try:
                os.makedirs(os.path.dirname(loc_file), exist_ok=True)
                with open(loc_file, 'w') as f:
                    json.dump(location_data, f, indent=2)
            except:
                pass
        
        # Also create a simpler version
        simple_data = {
            'lat': location_data['latitude'],
            'lng': location_data['longitude'],
            'country': 'GH',
            'timestamp': location_data['time']
        }
        
        simple_locations = [
            '/storage/emulated/0/location.json',
            '/sdcard/location.json'
        ]
        
        for loc_file in simple_locations:
            try:
                with open(loc_file, 'w') as f:
                    json.dump(simple_data, f)
            except:
                pass
        
        return True
    except:
        return False

def main():
    log("Starting Ghana location feeder...")
    
    injection_count = 0
    file_write_count = 0
    
    while True:
        try:
            location_data = create_location_data()
            
            # Try ADB injection
            if inject_through_adb(location_data):
                injection_count += 1
                if injection_count % 10 == 0:
                    log(f"Injected location {injection_count} times")
            
            # Write to files
            if write_location_files(location_data):
                file_write_count += 1
                if file_write_count % 10 == 0:
                    log(f"Updated location files {file_write_count} times")
            
            # Sleep with some randomness
            sleep_time = 5 + (fake.random.random() * 5)
            time.sleep(sleep_time)
            
        except KeyboardInterrupt:
            log("Location feeder stopped")
            break
        except Exception as e:
            log(f"Error: {str(e)}")
            time.sleep(10)

if __name__ == '__main__':
    main()
LOCEOF
    success "Location feeder created"
}

create_storage_poisoner() {
    cat > "$DECEIT_ROOT/storage/poisoner.py" << 'STOREOF'
#!/usr/bin/env python3
import os
import json
import time
import xml.etree.ElementTree as ET
from datetime import datetime
from faker import Faker

fake = Faker()
LOG_FILE = '/data/data/com.termux/files/home/.ghana_logs/storage.log'

def log(message):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    with open(LOG_FILE, 'a') as f:
        f.write(f'[{timestamp}] {message}\n')
    print(f'[STORAGE] {message}')

def create_shared_prefs():
    """Create fake shared preferences XML"""
    root = ET.Element('map')
    
    # String values
    string_items = {
        'user_country': 'GH',
        'user_region': 'Greater Accra',
        'user_city': 'Accra',
        'device_location': '5.6037,-0.1870',
        'last_known_ip': '41.204.0.100',
        'timezone': 'Africa/Accra',
        'language': 'en-GH'
    }
    
    for key, value in string_items.items():
        elem = ET.SubElement(root, 'string', {'name': key})
        elem.text = value
    
    # Boolean values
    bool_items = {
        'region_allowed': 'true',
        'location_enabled': 'true',
        'vpn_connected': 'false',
        'first_launch': 'false'
    }
    
    for key, value in bool_items.items():
        ET.SubElement(root, 'boolean', {'name': key, 'value': value})
    
    # Long values
    long_items = {
        'last_location_update': str(int(time.time() * 1000)),
        'first_install_time': str(fake.unix_time() * 1000),
        'last_region_check': str(int(time.time() * 1000))
    }
    
    for key, value in long_items.items():
        ET.SubElement(root, 'long', {'name': key, 'value': value})
    
    # Integer values
    int_items = {
        'app_version_code': '2066',
        'region_code': '233',
        'location_updates_count': str(fake.random.randint(100, 1000))
    }
    
    for key, value in int_items.items():
        ET.SubElement(root, 'int', {'name': key, 'value': value})
    
    # Convert to string
    rough_string = ET.tostring(root, 'utf-8')
    
    # Pretty print
    from xml.dom import minidom
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent='    ')

def create_cache_files():
    """Create various cache files"""
    cache_data = {
        'region_cache.json': {
            'country': 'GH',
            'country_code': 'GH',
            'region': 'Greater Accra',
            'city': 'Accra',
            'latitude': 5.6037,
            'longitude': -0.1870,
            'allowed': True,
            'timestamp': int(time.time() * 1000),
            'expires': int((time.time() + 86400) * 1000)
        },
        'ip_info.json': {
            'ip': '41.204.0.100',
            'country': 'Ghana',
            'country_code': 'GH',
            'region': 'AA',
            'city': 'Accra',
            'isp': 'Ghana Telecom',
            'latitude': 5.6037,
            'longitude': -0.1870
        },
        'app_config.json': {
            'region_override': 'GH',
            'force_location': True,
            'bypass_geo_check': True,
            'mock_location_enabled': True
        }
    }
    
    return cache_data

def poison_app_storage():
    """Poison all accessible app storage locations"""
    target_paths = [
        '/storage/emulated/0/Android/data/com.community.oneroom',
        '/storage/emulated/0/Android/media/com.community.oneroom',
        '/sdcard/Android/data/com.community.oneroom',
        '/storage/emulated/0/Android/obb/com.community.oneroom',
        '/data/data/com.termux/files/home/.oneRoom_ghana/storage'
    ]
    
    poisoned_count = 0
    
    for base_path in target_paths:
        try:
            # Create directories
            dirs_to_create = [
                f'{base_path}/shared_prefs',
                f'{base_path}/cache',
                f'{base_path}/files',
                f'{base_path}/files/cache',
                f'{base_path}/files/config'
            ]
            
            for directory in dirs_to_create:
                os.makedirs(directory, exist_ok=True)
            
            # Write shared preferences
            prefs_xml = create_shared_prefs()
            prefs_file = f'{base_path}/shared_prefs/region_prefs.xml'
            with open(prefs_file, 'w') as f:
                f.write(prefs_xml)
            poisoned_count += 1
            
            # Write cache files
            cache_files = create_cache_files()
            for filename, data in cache_files.items():
                cache_file = f'{base_path}/cache/{filename}'
                with open(cache_file, 'w') as f:
                    json.dump(data, f, indent=2)
                poisoned_count += 1
            
            # Write a simple flag file
            flag_file = f'{base_path}/files/ghana_mode.active'
            with open(flag_file, 'w') as f:
                f.write('GHANA_DECEPTION_ACTIVE')
            
            log(f"Poisoned: {base_path}")
            
        except Exception as e:
            # Silently continue if we can't write to a location
            pass
    
    return poisoned_count

def main():
    log("Starting storage poisoner...")
    
    cycle = 0
    while True:
        try:
            cycle += 1
            poisoned = poison_app_storage()
            
            if cycle % 5 == 0:
                log(f"Cycle {cycle}: Poisoned {poisoned} files/locations")
            
            # Sleep for 30-60 seconds
            sleep_time = 30 + (fake.random.random() * 30)
            time.sleep(sleep_time)
            
        except KeyboardInterrupt:
            log("Storage poisoner stopped")
            break
        except Exception as e:
            log(f"Error: {str(e)}")
            time.sleep(60)

if __name__ == '__main__':
    main()
STOREOF
    success "Storage poisoner created"
}

create_main_engine() {
    cat > "$DECEIT_ROOT/bin/engine.sh" << 'ENGINEEOF'
#!/data/data/com.termux/files/usr/bin/bash
# Main deception engine - controls all components

DECEIT_ROOT="$HOME/.oneRoom_ghana"
LOG_DIR="$HOME/.ghana_logs"
PID_DIR="$DECEIT_ROOT/pids"

start_component() {
    local name="$1"
    local script="$2"
    local pid_file="$PID_DIR/$name.pid"
    
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo "$name is already running (PID: $pid)"
            return 0
        fi
    fi
    
    echo "Starting $name..."
    cd "$DECEIT_ROOT/$(dirname "$script")"
    ./"$(basename "$script")" > "$LOG_DIR/$name.log" 2>&1 &
    echo $! > "$pid_file"
    echo "$name started with PID: $!"
}

stop_component() {
    local name="$1"
    local pid_file="$PID_DIR/$name.pid"
    
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            echo "Stopped $name (PID: $pid)"
        else
            echo "$name was not running"
        fi
        rm -f "$pid_file"
    else
        echo "$name is not running"
    fi
}

start_all() {
    echo "Starting Ghana Deception Engine..."
    
    # Set proxy
    settings put global http_proxy localhost:8080 2>/dev/null || true
    
    # Start components
    start_component "dns" "dns/spoofer.js"
    sleep 2
    start_component "http" "http/proxy.py"
    sleep 2
    start_component "location" "location/feeder.py"
    sleep 2
    start_component "storage" "storage/poisoner.py"
    
    # Force stop and restart target app
    am force-stop com.community.oneroom 2>/dev/null || true
    sleep 2
    
    # Launch with Ghana environment
    export http_proxy="http://localhost:8080"
    export https_proxy="http://localhost:8080"
    
    am start -n com.community.oneroom/.activity.SplashActivity \
        --es "mock_location" "true" \
        --ef "latitude" "5.6037" \
        --ef "longitude" "-0.1870" \
        --es "country" "GH" 2>/dev/null || \
    am start -a android.intent.action.MAIN \
        -c android.intent.category.LAUNCHER \
        -n com.community.oneroom/.activity.SplashActivity
    
    echo "Deception engine started successfully"
    echo "Check logs in: $LOG_DIR"
}

stop_all() {
    echo "Stopping Ghana Deception Engine..."
    
    # Remove proxy
    settings put global http_proxy :0 2>/dev/null || true
    
    # Stop components
    stop_component "storage"
    stop_component "location"
    stop_component "http"
    stop_component "dns"
    
    echo "Deception engine stopped"
}

status_all() {
    echo "Ghana Deception Engine Status"
    echo "=============================="
    
    for component in dns http location storage; do
        pid_file="$PID_DIR/$component.pid"
        if [ -f "$pid_file" ]; then
            pid=$(cat "$pid_file")
            if kill -0 "$pid" 2>/dev/null; then
                echo "✓ $component: RUNNING (PID: $pid)"
            else
                echo "✗ $component: DEAD (PID file exists: $pid)"
            fi
        else
            echo "✗ $component: STOPPED"
        fi
    done
    
    # Check if proxy is set
    proxy=$(settings get global http_proxy 2>/dev/null || echo "not set")
    echo "Proxy setting: $proxy"
    
    # Check target app
    if pgrep -f com.community.oneroom >/dev/null; then
        echo "Target app: RUNNING"
    else
        echo "Target app: STOPPED"
    fi
}

case "$1" in
    start)
        start_all
        ;;
    stop)
        stop_all
        ;;
    restart)
        stop_all
        sleep 3
        start_all
        ;;
    status)
        status_all
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
ENGINEEOF
    
    chmod +x "$DECEIT_ROOT/bin/engine.sh"
    success "Main engine created"
}

create_persistence() {
    cat > "$BOOT_DIR/01-ghana-deception" << 'BOOTEOF'
#!/data/data/com.termux/files/usr/bin/bash
# Auto-start Ghana Deception Engine on Termux boot

sleep 10  # Wait for system to stabilize

if [ -f "$HOME/.oneRoom_ghana/.enabled" ]; then
    echo "Starting Ghana Deception Engine (persistent)..."
    cd "$HOME/.oneRoom_ghana/bin"
    ./engine.sh start > "$HOME/.ghana_logs/boot.log" 2>&1 &
fi
BOOTEOF
    
    chmod +x "$BOOT_DIR/01-ghana-deception"
    
    # Create enable/disable scripts
    cat > "$DECEIT_ROOT/bin/enable-persistence.sh" << 'ENABLEEOF'
#!/data/data/com.termux/files/usr/bin/bash
touch "$HOME/.oneRoom_ghana/.enabled"
echo "Persistence enabled. Deception will auto-start on boot."
ENABLEEOF
    
    cat > "$DECEIT_ROOT/bin/disable-persistence.sh" << 'DISABLEEOF'
#!/data/data/com.termux/files/usr/bin/bash
rm -f "$HOME/.oneRoom_ghana/.enabled"
echo "Persistence disabled. Deception will not auto-start on boot."
DISABLEEOF
    
    chmod +x "$DECEIT_ROOT/bin/enable-persistence.sh"
    chmod +x "$DECEIT_ROOT/bin/disable-persistence.sh"
    
    success "Persistence system created"
}

create_installer() {
    cat > "$DECEIT_ROOT/bin/install.sh" << 'INSTALLEOF'
#!/data/data/com.termux/files/usr/bin/bash
# Installation script

echo "Installing Ghana Deception Engine..."
echo "This will set up the complete deception system."

# Copy engine to PATH
cp "$HOME/.oneRoom_ghana/bin/engine.sh" "$PREFIX/bin/ghana-deception"
chmod +x "$PREFIX/bin/ghana-deception"

# Install Node module
cd "$HOME/.oneRoom_ghana/dns"
npm install dns-packet --no-save >/dev/null 2>&1

# Install Python requirements
pip install faker >/dev/null 2>&1

echo "Installation complete!"
echo ""
echo "Available commands:"
echo "  ghana-deception start   - Start deception engine"
echo "  ghana-deception stop    - Stop deception engine"
echo "  ghana-deception status  - Check engine status"
echo "  ghana-deception restart - Restart engine"
echo ""
echo "Persistence control:"
echo "  $HOME/.oneRoom_ghana/bin/enable-persistence.sh"
echo "  $HOME/.oneRoom_ghana/bin/disable-persistence.sh"
INSTALLEOF
    
    chmod +x "$DECEIT_ROOT/bin/install.sh"
    
    # Create uninstaller
    cat > "$DECEIT_ROOT/bin/uninstall.sh" << 'UNINSTALLEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Uninstalling Ghana Deception Engine..."

# Stop if running
ghana-deception stop 2>/dev/null || true

# Remove from PATH
rm -f "$PREFIX/bin/ghana-deception"

# Remove boot script
rm -f "$HOME/.termux/boot/01-ghana-deception"

echo "Uninstallation complete."
echo "Note: Deception files in $HOME/.oneRoom_ghana were kept."
echo "Remove manually with: rm -rf $HOME/.oneRoom_ghana $HOME/.ghana_logs"
UNINSTALLEOF
    
    chmod +x "$DECEIT_ROOT/bin/uninstall.sh"
    success "Installer/uninstaller created"
}

create_readme() {
    cat > "$DECEIT_ROOT/README.md" << 'READMEEOF'
    }