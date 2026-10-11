#pragma once

#include <any>
#include <string>
#include <unordered_map>
#include <utility>

namespace Orion {

struct InitializationContext {
    using Values = std::unordered_map<std::string, std::any>;

    InitializationContext() = default;
    explicit InitializationContext(Values values) : values_(std::move(values)) {}

    bool contains(const std::string& key) const { return values_.contains(key); }

    template <typename T>
    const T& get(const std::string& key) const {
        return std::any_cast<const T&>(values_.at(key));
    }

    template <typename T>
    const T* tryGet(const std::string& key) const {
        const auto it = values_.find(key);
        return it == values_.end() ? nullptr : std::any_cast<T>(&it->second);
    }

    template <typename T>
    T getOr(const std::string& key, T fallback) const {
        const auto* value = tryGet<T>(key);
        return value ? *value : std::move(fallback);
    }

    template <typename T>
    void set(std::string key, T&& value) {
        values_.insert_or_assign(std::move(key), std::any(std::forward<T>(value)));
    }

private:
    Values values_;
};

} // namespace Orion
