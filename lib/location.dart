import 'package:akwap/akwap.dart';
import 'package:flutter/material.dart';

class LocationSelector extends StatefulWidget {
  const LocationSelector({super.key});

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  late final ValueNotifier<District?> district;
  late final ValueNotifier<County?> county;
  late final ValueNotifier<Subcounty?> subcounty;
  late final ValueNotifier<Parish?> parish;
  late final ValueNotifier<Village?> village;

  TextEditingController? districtController;
  TextEditingController? countyController;
  TextEditingController? subcountyController;
  TextEditingController? parishController;
  TextEditingController? villageController;

  final List<District> _districts = [];

  @override
  void initState() {
    super.initState();
    district = ValueNotifier(null);
    county = ValueNotifier(null);
    subcounty = ValueNotifier(null);
    parish = ValueNotifier(null);
    village = ValueNotifier(null);

    districts.then(
      (value) => setState(() {
        _districts
          ..clear()
          ..addAll(value..sort((a, b) => a.name.compareTo(b.name)));
      }),
    );
  }

  @override
  void dispose() {
    // district.dispose();
    // county.dispose();
    // subcounty.dispose();
    // parish.dispose();
    // village.dispose();
    // districtController?.dispose();
    // countyController?.dispose();
    // subcountyController?.dispose();
    // parishController?.dispose();
    // villageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Autocomplete<District>(
          optionsBuilder: (value) {
            final name = value.text.trim();
            if (name.isEmpty) {
              return _districts;
            }

            return _districts.findByName(name);
          },
          displayStringForOption: (option) => option.name,
          onSelected: (option) {
            district.value = option;
            county.value = null;
            countyController?.clear();

            subcounty.value = null;
            subcountyController?.clear();

            parish.value = null;
            parishController?.clear();

            village.value = null;
            villageController?.clear();
          },
          fieldViewBuilder: (
            context,
            textEditingController,
            focusNode,
            onFieldSubmitted,
          ) {
            districtController = textEditingController;

            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              onFieldSubmitted: (_) => onFieldSubmitted,
              validator: (_) {
                if (district.value?.name.trim().isNotEmpty != true) {
                  return 'District required';
                }

                return null;
              },
              decoration: const InputDecoration(labelText: 'District'),
            );
          },
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<District?>(
          valueListenable: district,
          builder: (context, d, child) {
            final counties = d?.counties ?? [];

            return Autocomplete<County>(
              key: ValueKey('district-${d?.id ?? "XXXX"}'),
              optionsBuilder: (value) {
                final name = value.text.trim();
                if (name.isEmpty) {
                  return counties;
                }

                return counties.findByName(name);
              },
              displayStringForOption: (option) => option.name,
              onSelected: (option) {
                county.value = option;

                subcounty.value = null;
                subcountyController?.clear();

                parish.value = null;
                parishController?.clear();

                village.value = null;
                villageController?.clear();
              },
              fieldViewBuilder: (
                context,
                textEditingController,
                focusNode,
                onFieldSubmitted,
              ) {
                countyController = textEditingController;

                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onFieldSubmitted: (_) => onFieldSubmitted,
                  validator: (_) {
                    if (county.value?.name.trim().isNotEmpty != true) {
                      return 'County required';
                    }

                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'County'),
                  enabled: district.value != null,
                );
              },
            );
          },
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<County?>(
          valueListenable: county,
          builder: (context, d, child) {
            final subcounties = d?.subcounties ?? [];

            return Autocomplete<Subcounty>(
              key: ValueKey('county-${d?.id ?? "XXXX"}'),
              optionsBuilder: (value) {
                final name = value.text.trim();
                if (name.isEmpty) {
                  return subcounties;
                }

                return subcounties.findByName(name);
              },
              displayStringForOption: (option) => option.name,
              onSelected: (option) {
                subcounty.value = option;

                parish.value = null;
                parishController?.clear();

                village.value = null;
                villageController?.clear();
              },
              fieldViewBuilder: (
                context,
                textEditingController,
                focusNode,
                onFieldSubmitted,
              ) {
                subcountyController = textEditingController;

                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onFieldSubmitted: (_) => onFieldSubmitted,
                  validator: (_) {
                    if (county.value?.name.trim().isNotEmpty != true) {
                      return 'Subcounty required';
                    }

                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Subcounty'),
                  enabled: county.value != null,
                );
              },
            );
          },
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<Subcounty?>(
          valueListenable: subcounty,
          builder: (context, d, child) {
            final subcounties = d?.parishes ?? [];

            return Autocomplete<Parish>(
              key: ValueKey('parish-${d?.id ?? "XXXX"}'),
              optionsBuilder: (value) {
                final name = value.text.trim();
                if (name.isEmpty) {
                  return subcounties;
                }

                return subcounties.findByName(name);
              },
              displayStringForOption: (option) => option.name,
              onSelected: (option) {
                parish.value = option;

                village.value = null;
                villageController?.clear();
              },
              fieldViewBuilder: (
                context,
                textEditingController,
                focusNode,
                onFieldSubmitted,
              ) {
                parishController = textEditingController;

                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onFieldSubmitted: (_) => onFieldSubmitted,
                  validator: (_) {
                    if (parish.value?.name.trim().isNotEmpty != true) {
                      return 'Parish required';
                    }

                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Parish'),
                  enabled: subcounty.value != null,
                );
              },
            );
          },
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<Parish?>(
          valueListenable: parish,
          builder: (context, d, child) {
            final subcounties = d?.villages ?? [];

            return Autocomplete<Village>(
              key: ValueKey('village-${d?.id ?? "XXXX"}'),
              optionsBuilder: (value) {
                final name = value.text.trim();
                if (name.isEmpty) {
                  return subcounties;
                }

                return subcounties.findByName(name);
              },
              displayStringForOption: (option) => option.name,
              onSelected: (option) {
                village.value = option;
              },
              fieldViewBuilder: (
                context,
                textEditingController,
                focusNode,
                onFieldSubmitted,
              ) {
                parishController = textEditingController;

                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onFieldSubmitted: (_) => onFieldSubmitted,
                  validator: (_) {
                    if (village.value?.name.trim().isNotEmpty != true) {
                      return 'Village required';
                    }

                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Village'),
                  enabled: parish.value != null,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
