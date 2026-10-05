# btrsd-backup-architecture

Transparent, deterministic, idempotent backup system designed around Unix systems that use Btrfs, Systemd, udev, and Bash.

Work in progress!

---

## Project Goals

- Outline an automated, layered recovery model (internal snapshot layer + external replication)
- **Internal snapshot layer**:
    - Optionally set up Snapper with optimal configuration for automatic local snapshots
- **External replication**:
    - Provide a system which will create local snapshots, manage them, and transmit them in a transparent, idempotent, and secure manner
    - External backup system is provided through Bash scripts, Systemd services and timers, and udev rules
- Outline deterministic recovery paths, without which the fully replicating snapshot backups would be meaningless

---

## Core Design Principles

- **Snapshot-driven system state** - System integrity is managed through structured snapshot creation and retention
- **Layered recovery architecture** - Internal snapshotting + rollback and external backups + recovery are treated as distinct layers
- **Minimal and transparent system design** – This architecture could easily pull in great external tools like btrback, BorgBackup, Kopia, Restic ... but instead, we examine how to satisfy an external recovery model with lower level tools. It's worth noting Snapper (a program for managing internal snapshots) is recommended for use alongisde this architecture
- **Intentional operation** – This is not a set-it-and-forget-it architecture. If it's anything, it's a platform for learning *how* one can manage their own backup model. You should look elsewhere if you're not interested in full transparency and control over your system!

---

## Status

**DON'T USE THIS!**

Well, feel free to comb through the scripts and run on a testbed system. Consider everything in this repository *untested*.

*Total system data loss* can very well occur if you blindly run any Bash scripts here.

This architecture and it's backup system were both developed and tested on an Arch Linux system. In that state, it wasn't quite ... safe. I have pivoted the project somewhat, and am also developing and testing mainly on Debian Linux. I have plans to test and outline functionality across as many Unix operating systems as I can get my hands on.

In general, the following haven't been implemented yet:
- NFS / network based backups
- Backup encryption

---

### Backups? What kind of backups?

*Backups*, in our case, can refer to any and all of the following:
- Locally stored snapshots of `root` and `/home`
    - Not *really* backups, more like internal, archival system state copies
- Externally stored snapshots of `root` and `/home`
- File-level copies of `/home`

### Ok, but what are snapshots?

*Snapshots* can be thought of as freeze-frame pictures of a subvolume. Snapshots and subvolumes are intrinsic to Btrfs, the file system type that this architecture assumes.

Snapshots are different from file-level copies, such as copying a PDF from your computer to a flash drive.

Snapshots can take up a **ridiculously** small amount of storage space in comparison to a file-level copy. This is thanks to Btrfs's copy-on-write nature.

Consider the following: you take a snapshot of a subvolume on your Btrfs system, and store it locally. On your Btrfs formatted storage device, all of the data is not written twice. Btrfs keeps track of the snapshot's data and your current data cleverly - using the same blocks of storage to keep track of data that 'exists' on both your current system and on the snapshot's recollection of your system.

In this architecture, we make use of the fact that *multiple* backups of the same system, when stored on the same external device, take up less space than multiple file-level system backups.

### Oh, I get it!

Yeah!

### But, what's a udev? Or a ... Bash?

This architecture is fully documented in the form of markdown files, which can be viewed here:
- [docs](./docs/) (docs/)
