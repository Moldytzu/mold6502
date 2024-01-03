from py65emu.cpu import CPU
from py65emu.mmu import MMU
import sys

# open the ROM
rom = open(sys.argv[1], "rb")

# (start_address, length, readOnly=True, value=None, valueOffset=0)
memory = MMU([
        (0x00, 0x8000), # RAM 32k
        (0x8000, 0x4000), # I/O 16k
        (0xC000, 0x4000, True, rom) # ROM 16k
])

cpu = CPU(memory, memory.readWord(0xFFFC)) # point the start of the program to the reset vector stored in ROM

# very basic 6522 VIA emulation
class VIA:
    base_address = 0
    ddra = 0 # inputs
    ddrb = 0 # inputs
    ora = 0xFF  # all inputs are pulled up
    orb = 0xFF  # all inputs are pulled up
    memory = None
    
    def __init__(self, memory, base):
        self.base_address = base
        self.memory = memory
        
        # initialise the memory region
        self.memory.write(self.base_address + 0, self.orb)
        self.memory.write(self.base_address + 1, self.ora)
        self.memory.write(self.base_address + 2, self.ddrb)
        self.memory.write(self.base_address + 3, self.ddra)
    
    def update(self):
        # read the updated state from memory
        self.orb = self.memory.read(self.base_address + 0)
        self.ora = self.memory.read(self.base_address + 1)
        self.ddrb = self.memory.read(self.base_address + 2)
        self.ddra = self.memory.read(self.base_address + 3)
        
        # process the state
        
        
        # update the memory region with internal state
        self.memory.write(self.base_address + 0, self.orb)
        self.memory.write(self.base_address + 1, self.ora)
        self.memory.write(self.base_address + 2, self.ddrb)
        self.memory.write(self.base_address + 3, self.ddra)
        
    def dump_state(self):
        print(f"BASE:{hex(self.base_address)} DDRA:{hex(self.ddra)} DDRB:{hex(self.ddrb)} ORA:{hex(self.ora)} ORB:{hex(self.orb)}")

# very basic 16x2 LCD emulation
class LCD:
    via_parent = None
    
    def __init__(self, via):
        self.via_parent = via
    
    last_state = False
    def update(self):
        via = self.via_parent
        enabled = via.ora & 0x40 > 0
        if self.last_state == True and enabled == False: # falling edge
            if via.ora & 0x20: # data
                print(chr(via.orb),end='')
            else: # instruction
                pass # todo: handle instructions
        self.last_state = enabled

via1 = VIA(memory, 0xA000)
lcd = LCD(via1)

total_cycles = 0
def dump_cpu_state():
    print(f"A:{hex(cpu.r.a)} X:{hex(cpu.r.x)} Y:{hex(cpu.r.y)} SP:{hex(cpu.r.s)} PC:{hex(cpu.r.pc)} CYCLES:{total_cycles}")

# run n instructions
while True:
    # update components
    cpu.step()
    via1.update()
    lcd.update()
    total_cycles += cpu.cc
    
    if cpu.r.pc == 0xFFFF:
        #print("HALT")
        break
    
    # dump state
    #dump_cpu_state()
    #via1.dump_state()