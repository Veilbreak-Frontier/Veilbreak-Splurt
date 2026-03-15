# tgui/packages/common/collections.ts

// Add a new class to handle bodycam functionality
class Bodycam {
  constructor(private active: boolean = false) {}

  // Method to activate the bodycam
  activate() {
    this.active = true;
    console.log("Bodycam activated.");
  }

  // Method to deactivate the bodycam
  deactivate() {
    this.active = false;
    console.log("Bodycam deactivated.");
  }

  // Method to check if the bodycam is active
  isActive() {
    return this.active;
  }
}

// Add a new method to the SecurityArmor class to integrate bodycam functionality
class SecurityArmor {
  private bodycam: Bodycam;

  constructor() {
    this.bodycam = new Bodycam();
  }

  // Method to activate the bodycam
  activateBodycam() {
    this.bodycam.activate();
  }

  // Method to deactivate the bodycam
  deactivateBodycam() {
    this.bodycam.deactivate();
  }

  // Method to check if the bodycam is active
  isBodycamActive() {
    return this.bodycam.isActive();
  }
}

// Example usage
const armor = new SecurityArmor();
armor.activateBodycam();
console.log(armor.isBodycamActive()); // true
armor.deactivateBodycam();
console.log(armor.isBodycamActive()); // false