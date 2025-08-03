import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool isEditingProfile = false;

  Map<String, dynamic> profile = {
    'name': 'imnuget',
    'username': '@nuget',
    'email': 'nuget@email.com',
    'bio': 'Digital creator sharing my journey 📸 Coffee enthusiast ☕ Always exploring new places ✈️',
    'location': 'South Korea, SK',
    'website': 'nuget.com',
    'followers': 2847,
    'following': 892,
    'posts': 24,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(
            icon: Icon(isEditingProfile ? Icons.close : Icons.settings),
            onPressed: () {
              setState(() {
                isEditingProfile = !isEditingProfile;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileSection(),
            const SizedBox(height: 20),
            _buildStatsSection(),
            const SizedBox(height: 20),
            _buildBioAndLinks(),
            if (isEditingProfile) _buildEditButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage('assets/avatar.png'), // 너가 준비한 이미지로 교체
            ),
            if (isEditingProfile)
              const Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.camera_alt, size: 18),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: isEditingProfile
              ? Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Name"),
                controller: TextEditingController(text: profile['name']),
                onChanged: (value) => profile['name'] = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Username"),
                controller: TextEditingController(text: profile['username']),
                onChanged: (value) => profile['username'] = value,
              ),
            ],
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(profile['username'], style: const TextStyle(color: Colors.grey)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStat("Posts", profile['posts']),
        _buildStat("Followers", profile['followers']),
        _buildStat("Following", profile['following']),
      ],
    );
  }

  Widget _buildStat(String label, int value) {
    return Column(
      children: [
        Text(value.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildBioAndLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isEditingProfile)
          Text(profile['bio'], style: const TextStyle(fontSize: 14))
        else
          TextField(
            decoration: const InputDecoration(labelText: "Bio"),
            controller: TextEditingController(text: profile['bio']),
            onChanged: (value) => profile['bio'] = value,
          ),
        const SizedBox(height: 10),
        if (!isEditingProfile) ...[
          if (profile['location'] != null)
            Text("📍 ${profile['location']}", style: const TextStyle(fontSize: 14)),
          if (profile['website'] != null)
            Text("🔗 ${profile['website']}", style: const TextStyle(fontSize: 14, color: Colors.blue)),
        ] else ...[
          TextField(
            decoration: const InputDecoration(labelText: "Location"),
            controller: TextEditingController(text: profile['location']),
            onChanged: (value) => profile['location'] = value,
          ),
          TextField(
            decoration: const InputDecoration(labelText: "Website"),
            controller: TextEditingController(text: profile['website']),
            onChanged: (value) => profile['website'] = value,
          ),
        ],
      ],
    );
  }

  Widget _buildEditButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() => isEditingProfile = false);
              // 저장 로직 추가
            },
            icon: const Icon(Icons.save),
            label: const Text("Save Changes"),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() => isEditingProfile = false),
            child: const Text("Cancel"),
          ),
        ),
      ],
    );
  }
}
