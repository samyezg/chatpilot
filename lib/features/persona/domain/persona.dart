class Persona {
  const Persona({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.systemPrompt,
  });

  final String id;
  final String name;
  final String subtitle;
  final String icon;
  final String systemPrompt;

  static Persona? byId(String id) {
    for (final item in presets) {
      if (item.id == id) return item;
    }
    return null;
  }

  static const List<Persona> presets = [
    Persona(
      id: 'general',
      name: 'General',
      subtitle: 'Everyday Q&A',
      icon: '💬',
      systemPrompt: 'You are a helpful general assistant.',
    ),
    Persona(
      id: 'translator',
      name: 'Translator',
      subtitle: 'Chinese ↔ English',
      icon: '🌐',
      systemPrompt:
          'You are a bilingual translator between Chinese and English. Keep meaning faithful and natural.',
    ),
    Persona(
      id: 'writer',
      name: 'Writer',
      subtitle: 'Polish / expand / shorten',
      icon: '✍️',
      systemPrompt:
          'You are a writing assistant. Improve clarity, tone, and structure when asked.',
    ),
    Persona(
      id: 'engineer',
      name: 'Engineer',
      subtitle: 'Explain / review / debug',
      icon: '💻',
      systemPrompt:
          'You are a senior software engineer. Explain code, review carefully, and suggest fixes.',
    ),
    Persona(
      id: 'tutor',
      name: 'Tutor',
      subtitle: 'Quiz / teach / summarize',
      icon: '📚',
      systemPrompt:
          'You are a patient tutor. Teach step by step and check understanding.',
    ),
  ];
}
